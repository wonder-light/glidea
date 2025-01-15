library;

import 'dart:async' show Completer;
import 'dart:io' show Directory, HttpServer;
import 'dart:isolate' show Isolate, ReceivePort, SendPort;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show protected;
import 'package:flutter/services.dart' show BackgroundIsolateBinaryMessenger, RootIsolateToken, rootBundle;
import 'package:glidea/helpers/deploy/deploy.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/render/render.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/setting.dart';
import 'package:glidea/models/worker.dart';
import 'package:logger/logger.dart' show Level;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory, getApplicationSupportDirectory;
import 'package:shelf/shelf_io.dart' as shelf_io show serve;
import 'package:shelf_static/shelf_static.dart' show createStaticHandler;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

part 'action.dart';

/// 基础线程
abstract class BaseWorker {
  BaseWorker({int startKey = 0, ReceivePort? receive}) {
    _startKey = startKey;
    this.receive = receive ?? ReceivePort();
    onInit();
  }

  /// 接收端口
  late final ReceivePort receive;

  /// 发送数据给隔离的发送端口
  late final SendPort send;

  /// 任务开始的索引
  int _startKey = 0;

  /// 记录的任务
  final Map<int, Completer> _tasks = {};

  Map<int, Completer> get tasks => _tasks;

  /// 记录自身需要被调用的函数
  final Map<Symbol, Function> _invokes = {};

  /// 初始化数据
  @protected
  Future<void> onInit() async {}

  /// 其它进程发送消息给自己时接收数据
  @protected
  void receiveData(dynamic param) {
    if (param is ReceiveData) {
      // 是接收就更新任务
      updateTask(param);
    } else if (param is SendData) {
      // 是发生就调用自身函数并发送对应的数据
      sendData(param);
    } else {
      throw StateError('background worker receive data is not subtype ReceiveData');
    }
  }

  /// 接收到 [ReceiveData] 数据时就更新任务
  @protected
  void updateTask(ReceiveData param) {
    // 接受数据
    if (param.data is SendPort) {
      send = param.data;
    }
    final task = _tasks.remove(param.id);
    if (param.error != null) {
      task?.completeError(param.error!, param.stackTrace);
    } else {
      task?.complete(param.data);
    }
  }

  /// 接收到 [SendData] 数据时就调用自身函数并发送对应的数据
  @protected
  void sendData(SendData param) async {
    try {
      dynamic result = await invoke(param.invocation);
      send.send(ReceiveData(id: param.id, data: result));
    } catch (e, s) {
      send.send(ReceiveData(id: param.id, error: e, stackTrace: s));
    }
  }

  /// 调用其它进程中的任务
  @protected
  Future<T> call<T>(Symbol memberName, [Iterable<Object?>? positionalArguments, Map<Symbol, Object?>? namedArguments]) {
    final task = _tasks[++_startKey] = Completer<T>();
    send.send(SendData(id: _startKey, invocation: Invocation.method(memberName, positionalArguments, namedArguments)));
    return task.future;
  }

  /// 调用自身的函数发送对应的数据
  @protected
  Future<dynamic> invoke(Invocation invocation) async {
    final fun = _invokes[invocation.memberName];
    if (fun == null) return;
    return Function.apply(fun, invocation.positionalArguments, invocation.namedArguments);
  }
}

/// 管理后台进程
base class BackgroundWorker extends BaseWorker {
  BackgroundWorker({super.receive, super.startKey});

  /// 进程的初始化任务
  final Completer initTask = Completer<void>();

  /// 当前的 [Isolate]
  late final Isolate isolate;

  /// 退出进程
  void exit() => isolate.kill(priority: Isolate.immediate);

  /// 初始化 [isolate]
  @override
  @protected
  Future<void> onInit() async {
    // 初始化任务 ID
    final initTaskId = ++_startKey;
    // 初始化任务
    _tasks[initTaskId] = initTask;
    // 初始化数据
    final initData = (token: RootIsolateToken.instance!, send: receive.sendPort);
    // 监听
    receive.listen(receiveData);
    // 生成
    isolate = await Isolate.spawn((params) async {
      // 初始化
      BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);
      await Log.initialized(background: true);
      JsonHelp.initialized();
      // 创建 [_BackgroundProcess]
      BackgroundProcess.instance = BackgroundProcess(send: params.send, id: initTaskId);
    }, initData);
    // 返回任务
    return initTask.future;
  }
}

/// 后台进程, 对 [BackgroundWorker] 的一个封装
final class Background extends BackgroundWorker with BackgroundAction {
  static Background? _instance;

  /// 用于控制后台实例
  static Background get instance {
    if (_instance == null) {
      throw StateError('The Background.instance value is invalid ');
    }
    return _instance!;
  }

  /// 初始化 [Background] 的 [instance]
  static Future<void> initialized() async {
    _instance = Background();
  }
}

/// 数据处理进程
base class WorkerProcess extends BaseWorker {
  WorkerProcess({required SendPort send, super.receive, int id = 0}) {
    this.send = send;
    receive.listen(receiveData);
    // 发送 sendPort
    this.send.send(ReceiveData(id: id, data: receive.sendPort));
  }
}

/// 后台数据处理进程
final class BackgroundProcess extends WorkerProcess with ActionBack, RemoteBack, DataBack {
  BackgroundProcess({required super.send, super.receive, super.id});

  /// 先前台发送信息的实例
  static BackgroundProcess? instance;
}

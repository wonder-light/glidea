import 'dart:collection' show ListQueue;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:glidea/helpers/fs.dart';
import 'package:logger/logger.dart' show AdvancedFileOutput, Level, Logger, MemoryOutput, MultiOutput, OutputEvent, ProductionFilter;
import 'package:path_provider/path_provider.dart' show getApplicationSupportDirectory;

class Log {
  // [Logger] 实例
  static late final Logger instance;

  static late final ListQueue<OutputEvent> buffer;

  /// 应用程序当前的日志级别.
  ///
  /// 所有低于此级别的日志将被忽略
  static Level get level => Logger.level;

  static set level(Level logLevel) => Logger.level = logLevel;

  /// 初始化
  static Future<void> initialized() async {
    Level level = kReleaseMode ? Level.info : Level.trace;
    // 流输出
    MemoryOutput memoryOutput = MemoryOutput(bufferSize: 50);
    buffer = memoryOutput.buffer;
    // 列表
    final lists = [if (!kReleaseMode) Logger.defaultOutput(), memoryOutput];
    // 文件输出
    if (kReleaseMode) {
      // 应用程序支持目录, 即配置所在的目录
      var path = FS.normalize((await getApplicationSupportDirectory()).path);
      path = FS.join(path, 'log');
      FS.createDirSync(path);
      lists.add(AdvancedFileOutput(path: path));
    }
    // 实例化
    instance = Logger(filter: ProductionFilter(), output: MultiOutput(lists), level: level);
  }

  /// 是否 log 资源
  static Future<void> dispose() async {
    await Log.instance.close();
  }

  /// 在级别记录消息 [Level.trace]
  static void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.debug]
  static void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.info]
  static void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.warning]
  static void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.error]
  static void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 在级别记录消息 [Level.fatal]
  static void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.f(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 用 [Log.level] 级别记录消息
  static void log(Level level, dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    Log.instance.log(level, message, time: time, error: error, stackTrace: stackTrace);
  }
}

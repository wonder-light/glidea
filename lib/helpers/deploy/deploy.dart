import 'dart:convert' show ascii, utf8;
import 'dart:io' show HttpClient;

import 'package:dio/dio.dart' show BaseOptions, Dio, InterceptorsWrapper, Response;
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/crypto.dart';
import 'package:glidea/helpers/deploy/gitee.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/setting.dart';

import 'github.dart';
import 'netlify.dart';
import 'sftp.dart';

export 'gitee.dart';
export 'github.dart';
export 'netlify.dart';
export 'sftp.dart';

/// 部署抽象类
abstract class Deploy {
  Deploy(Application site, {String? api = '', String? token = ''}) {
    appDir = site.appDir;
    buildDir = site.buildDir;
    remote = site.remote;
    if (api != null) this.api = api;
    if (token != null) this.token = token;
    // 更新代理
    _updateProxy(site);
  }

  /// 文件所在的目录
  late final String appDir;

  /// 产生的部分文本存放的目录
  late final String buildDir;

  /// API 接口
  late final String api;

  /// 令牌
  late final String token;

  // 远程设置
  late final RemoteSetting remote;

  /// HTTP 请求
  static Dio get dio => _dio ??= _createDio();
  static Dio? _dio;

  /// 发布
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  Future<void> publish();

  /// 远程检测
  ///
  /// 检测出错时抛出 [Mistake] 异常类
  Future<void> remoteDetect() async => throw Mistake(message: 'Deploy.remoteDetect no corresponding implementation');

  /// 创建部署
  static Deploy create(Application site) {
    return switch (site.remote.platform) {
      DeployPlatform.netlify => NetlifyDeploy(site),
      DeployPlatform.github => GithubDeploy(site),
      DeployPlatform.gitee => GiteeDeploy(site),
      DeployPlatform.sftp => SftpDeploy(site),
      // TODO: Handle this case.
      DeployPlatform.coding => throw UnimplementedError(),
    };
  }

  /// 创建 [Dio] 实例
  static Dio _createDio() {
    final options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveDataWhenStatusError: true,
    );
    return Dio(options)
      ..interceptors.add(InterceptorsWrapper(
        onError: (error, handler) {
          // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
          if (error.response != null) {
            return handler.resolve(error.response!);
          }
          return handler.next(error);
        },
      ));
  }

  /// 设置代理
  void _updateProxy(Application site) {
    if (dio.httpClientAdapter is! IOHttpClientAdapter) return;
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient ??= () {
      return HttpClient()
        ..findProxy = (uri) {
          // 将请求代理至 localhost:8888。
          // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
          // 'DIRECT; PROXY localhost:8888'
          final remote = site.remote;
          return remote.enabledProxy == ProxyWay.proxy ? 'PROXY ${remote.proxyPath}:${remote.proxyPort}' : 'DIRECT';
        };
    };
  }
}

/// git 部署
abstract class GitDeploy extends Deploy {
  GitDeploy(super.site, {super.api = null, super.token = null});

  @override
  Future<void> publish() async {
    await getOrCreateBranches();
    await createCommits();
    await updatePages();
  }

  /// 获取分支, 当分支不存在时进行创建
  ///
  /// 如果输出现错误时抛出 [Mistake] 异常类
  Future<void> getOrCreateBranches();

  /// 为输出的文件创建一个提交, 并推送到远程的管理平台上
  ///
  /// 如果输出现错误时抛出 [Mistake] 异常类
  Future<void> createCommits();

  /// 更新 Git Pages
  ///
  /// 如果不存在则创建,
  ///
  /// 更新 Pages 信息
  ///
  /// 构建和部署 Pages
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  Future<void> updatePages();

  /// 返回路径为 [path] 的文件的 blob sha 值
  Future<String> getFileBlobSha(String path) async {
    final bytes = await FS.readAsBytes(path);
    final head = utf8.encode('blob ${bytes.length}${ascii.decode([0])}');
    return await Crypto.cryptoBytes(head + bytes);
  }
}

extension ResponseExt<T> on Response<T> {
  /// 检测状态代码是否异常, 如果有异常, 则抛出 [Mistake] 错误
  void checkStateCode({int? equal, List<int>? exclude, bool normal = true}) {
    if (equal != null && statusCode != equal) {
      throw Mistake(message: 'current state code is $statusCode, but it is not equal $equal}');
    }
    if (exclude != null && exclude.any((t) => t == statusCode)) {
      throw Mistake(message: 'current state code is $statusCode, but it is not in $exclude}');
    }
    if (statusCode case int code when normal && (code < 200 || code > 299)) {
      throw Mistake.add(message: 'current state code is $statusCode, it is not error code', error: data.toString());
    }
  }
}

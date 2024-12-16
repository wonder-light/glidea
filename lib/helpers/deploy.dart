import 'dart:io';

import 'package:dio/dio.dart' show Dio, Options, Response;
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/setting.dart';

/// 部署抽象类
abstract class Deploy {
  Deploy(Application site)
      : appDir = site.appDir,
        buildDir = site.buildDir,
        remote = site.remote {
    // 更新代理
    _updateProxy(site);
  }

  /// 文件所在的目录
  final String appDir;

  /// 产生的部分文本存放的目录
  final String buildDir;

  // 远程设置
  final RemoteSetting remote;

  /// HTTP 请求
  static Dio get dio => (_dio ??= Dio());
  static Dio? _dio;

  /// 发布
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  Future<void> publish();

  /// 远程检测
  ///
  /// 检测出错时抛出 [Mistake] 异常类
  Future<void> remoteDetect() async => true;

  /// 创建部署
  static Deploy create(Application site) {
    return switch (site.remote.platform) {
      DeployPlatform.netlify => NetlifyDeploy(site),
      DeployPlatform.github || DeployPlatform.coding || DeployPlatform.gitee => GitDeploy(site),
      DeployPlatform.sftp => SftpDeploy(site),
    };
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

/// Netlify 部署
class NetlifyDeploy extends Deploy {
  NetlifyDeploy(super.site)
      : apiUrl = 'https://api.netlify.com/api/v1/',
        siteId = site.remote.netlifySiteId,
        accessToken = 'Bearer ${site.remote.netlifyAccessToken}',
        _deployId = '',
        header = {
          'User-Agent': 'Glidea',
          'Authorization': 'Bearer ${site.remote.netlifyAccessToken}',
        };

  /// Netlify 的 API 接口
  final String apiUrl;

  /// Netflix访问令牌
  final String accessToken;

  /// Netflix ID
  final String siteId;

  /// 请求头
  final Map<String, dynamic> header;

  String _deployId;

  @override
  Future<void> publish() async {
    // 详情请看
    // https://docs.netlify.com/api/get-started/#deploy-with-the-api
    final fileList = await prepareLocalFilesList();
    // 需要上传的文件的哈希值
    final hashOfFilesToUpload = await requestFiles(fileList);
    // 异常
    final mistake = Mistake(message: 'netlify deploy upload file failed', hint: 'connectFailed');
    // 开始上传
    for (var filePath in hashOfFilesToUpload) {
      // 出错时尝试两次
      try {
        var result = await uploadFile(filePath);
        if (result.statusCode == 422) {
          throw mistake;
        }
      } catch (e) {
        var result = await uploadFile(filePath);
        if (result.statusCode == 422) {
          throw mistake;
        }
      }
    }
  }

  @override
  Future<void> remoteDetect() async {
    try {
      final result = await Deploy.dio.get('${apiUrl}sites/$siteId', options: Options(headers: header));
      if (result.statusCode != 200) {
        throw Mistake(message: 'Netlify remote detect error, response statusCode is not 200');
      }
    } catch (e) {
      throw Mistake(message: 'Netlify remote detect failed: \n$e');
    }
  }

  /// 准备本地文件列表
  Future<TMap<String>> prepareLocalFilesList() async {
    final TMap<String> fileList = {};
    for (var item in FS.getFilesSync(buildDir)) {
      // "/index.html": "907d14fb3af2b0d4f18c2d46abe8aedce17367bd"
      var path = FS.relative(item.path, buildDir);
      if (!path.startsWith('/')) {
        path = '/$path';
      }
      fileList[path] = await item.getHash();
    }
    return fileList;
  }

  /// 获取需要上传的文件
  ///
  /// throw [Mistake] exception
  Future<List<String>> requestFiles(TMap<String> fileList) async {
    try {
      final data = {'files': fileList};
      final result = await Deploy.dio.post(
        '${apiUrl}sites/$siteId/deploys',
        data: data,
        options: Options(headers: header),
      );
      // 设置 _deployId
      _deployId = result.data['id'];
      List<String> lists = (result.data['required'] as List).cast<String>();
      // "/index.html": "907d14fb3af2b0d4f18c2d46abe8aedce17367bd" =>
      // "907d14fb3af2b0d4f18c2d46abe8aedce17367bd": "/index.html"
      fileList = fileList.map((k, v) => MapEntry(v, k));
      // 获取对应的路径
      return lists.map((item) => fileList[item]!).toList();
    } catch (e) {
      throw Mistake(message: 'netlify request file failed: \n$e', hint: 'connectFailed');
    }
  }

  /// 上传文件
  Future<Response> uploadFile(String filePath) async {
    final fullFilePath = FS.join(buildDir, filePath);
    final fileContent = await File(fullFilePath).readAsBytes();
    final headers = header.mergeMaps({'Content-Type': 'application/octet-stream'});
    // 上传
    return await Deploy.dio.put(
      '${apiUrl}deploys/$_deployId/files$filePath',
      data: fileContent,
      options: Options(headers: headers),
    );
  }
}

/// Git 部署, 包括 github、gitee、coding
class GitDeploy extends Deploy {
  GitDeploy(super.site)
      : platform = site.remote.platform,
        remoteUrl = '';

  /// 远程 URL
  final String remoteUrl;

  /// 指定的 Git 的平台
  final DeployPlatform platform;

  @override
  Future<void> publish() async {
    // TODO: implement publish
    throw UnimplementedError();
  }
}

/// SFTP 部署
class SftpDeploy extends Deploy {
  SftpDeploy(super.site);

  @override
  Future<void> publish() async {
    // TODO: implement publish
    throw UnimplementedError();
  }
}

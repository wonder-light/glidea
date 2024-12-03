import 'dart:io';

import 'package:dio/dio.dart' show Dio, Options, Response;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/setting.dart';

/// 部署抽象类
abstract class Deploy {
  Deploy(Application site)
      : appDir = site.appDir,
        buildDir = site.buildDir,
        remote = site.remote;

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
  Future<Incident> publish();

  /// 远程检测
  Future<bool> remoteDetect() async => true;

  /// 创建部署
  static Deploy create(Application site) {
    return switch (site.remote.platform) {
      DeployPlatform.netlify => NetlifyDeploy(site),
      DeployPlatform.github || DeployPlatform.coding || DeployPlatform.gitee => GitDeploy(site),
      DeployPlatform.sftp => SftpDeploy(site),
    };
  }
}

/// Netlify 部署
class NetlifyDeploy extends Deploy {
  NetlifyDeploy(
    super.site, {
    this.apiUrl = 'https://api.netlify.com/api/v1/',
  })  : accessToken = site.remote.netlifyAccessToken,
        siteId = site.remote.netlifySiteId,
        _deployId = '';

  /// Netlify 的 API 接口
  final String apiUrl;

  /// Netflix访问令牌
  final String accessToken;

  /// Netflix ID
  final String siteId;

  String _deployId;

  @override
  Future<Incident> publish() async {
    try {
      /// 详情请看
      /// https://docs.netlify.com/api/get-started/#deploy-with-the-api
      final fileList = await prepareLocalFilesList();
      // 需要上传的文件的哈希值
      final hashOfFilesToUpload = await requestFiles(fileList);
      for (var filePath in hashOfFilesToUpload) {
        // 出错时尝试两次
        try {
          var result = await uploadFile(filePath);
          if (result.statusCode == 422) {
            throw Incident.deployError422;
          }
        } catch (e) {
          var result = await uploadFile(filePath);
          if (result.statusCode == 422) {
            return Incident.deployError422;
          }
        }
      }
    } catch (e) {
      return Incident.connectFailed;
    }
    return Incident.success;
  }

  /// 准备本地文件列表
  Future<TMap<String>> prepareLocalFilesList() async {
    final TMap<String> fileList = {};
    for (var item in await FS.getFiles(buildDir).toList()) {
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
  Future<List<String>> requestFiles(TMap<String> fileList) async {
    final data = {'files': fileList};
    final result = await Deploy.dio.post(
      '${apiUrl}sites/$siteId/deploys',
      data: data,
      options: Options(
        headers: {
          'User-Agent': 'Glidea',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    // 设置 _deployId
    _deployId = result.data['id'];
    List<String> lists = result.data['required'];
    // "/index.html": "907d14fb3af2b0d4f18c2d46abe8aedce17367bd" =>
    // "907d14fb3af2b0d4f18c2d46abe8aedce17367bd": "/index.html"
    fileList = fileList.map((k, v) => MapEntry(v, k));
    // 获取对应的路径
    return lists.map((item) => fileList[item]!).toList();
  }

  /// 上传文件
  Future<Response> uploadFile(String filePath) async {
    final fullFilePath = FS.joinR(buildDir, filePath);
    final fileContent = await File(fullFilePath).readAsBytes();
    // 上传
    return await Deploy.dio.put(
      '${apiUrl}deploys/$_deployId/files$filePath',
      data: fileContent,
      options: Options(
        headers: {
          'User-Agent': 'Glidea',
          'Content-Type': 'application/octet-stream',
          'Authorization': 'Bearer $accessToken',
        },
      ),
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
  Future<Incident> publish() async {
    // TODO: implement publish
    throw UnimplementedError();
  }
}

/// SFTP 部署
class SftpDeploy extends Deploy {
  SftpDeploy(super.site);

  @override
  Future<Incident> publish() async {
    // TODO: implement publish
    throw UnimplementedError();
  }
}

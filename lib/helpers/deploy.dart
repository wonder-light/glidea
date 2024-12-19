import 'dart:convert';
import 'dart:io' show File, HttpClient;

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
  Deploy(Application site) {
    appDir = site.appDir;
    buildDir = site.buildDir;
    remote = site.remote;
    // 更新代理
    _updateProxy(site);
  }

  /// 文件所在的目录
  late final String appDir;

  /// 产生的部分文本存放的目录
  late final String buildDir;

  // 远程设置
  late final RemoteSetting remote;

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
  Future<void> remoteDetect() async => throw Mistake(message: 'Deploy.remoteDetect no corresponding implementation');

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
  NetlifyDeploy(Application site) : super(site) {
    apiUrl = 'https://api.netlify.com/api/v1/';
    siteId = site.remote.netlifySiteId;
    token = 'Bearer ${site.remote.netlifyAccessToken}';
    deployId = '';
    header = {
      'User-Agent': 'Glidea',
      'Authorization': token,
    };
  }

  /// Netlify 的 API 接口
  late final String apiUrl;

  /// Netflix访问令牌
  late final String token;

  /// Netflix ID
  late final String siteId;

  /// 请求头
  late final Map<String, dynamic> header;

  /// 部署的 id
  late String deployId;

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
        throw Mistake(message: 'response statusCode is not 200');
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
      final options = Options(headers: header);
      final data = {'files': fileList};
      final result = await Deploy.dio.post('${apiUrl}sites/$siteId/deploys', data: data, options: options);
      // 设置 _deployId
      deployId = result.data['id'];
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
    final options = Options(headers: {...header, 'Content-Type': 'application/octet-stream'});
    final fileContent = await File(FS.join(buildDir, filePath)).readAsBytes();
    // 上传
    return await Deploy.dio.put('${apiUrl}deploys/$deployId/files$filePath', data: fileContent, options: options);
  }
}

/// Git 部署, 包括 github、gitee、coding
///
/// 更多请查看详情 [github API git](https://docs.github.com/zh/rest/authentication/endpoints-available-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#git)
class GitDeploy extends Deploy {
  GitDeploy(Application site) : super(site) {
    git = site.remote.copy<RemoteCoding>()!;
    apiUrl = switch (site.remote.platform) {
      DeployPlatform.github => 'https://api.github.com/repos/${site.remote.username}/${site.remote.repository}',
      DeployPlatform.coding => throw UnimplementedError(),
      DeployPlatform.gitee => 'https://gitee.com/api/v5/repos/${site.remote.username}/${site.remote.repository}',
      _ => throw Mistake(message: 'GitDeploy: current selected deploy platform is not github | gitee | coding'),
    };
    token = 'Bearer ${site.remote.token}';
    headers = {
      'User-Agent': 'Glidea',
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer ${site.remote.token}',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json',
    };
  }

  /// api URL
  late final String apiUrl;

  /// 令牌
  late final String token;

  /// git 配置
  late final RemoteCoding git;

  /// 请求头
  late final Map<String, dynamic> headers;

  @override
  Future<void> remoteDetect() async {
    try {
      // 检测仓库是否存在
      final result = await Deploy.dio.get(apiUrl);
      if (result.statusCode != 200) {
        throw Mistake(message: 'response statusCode is not 200');
      }
    } catch (e) {
      throw Mistake(message: '${git.platform.name} remote detect failed: \n$e');
    }
  }

  @override
  Future<void> publish() async {
    final sha = await _getTreeAndCommitSha();
    final fileSha = await _createBlobSha();
    final newTreeSha = await _createTree(fileSha, sha.treeSha);
    final newCommitSha = await _generateCommit(sha.commitSha, newTreeSha);
    await _updateRef(newCommitSha);
    await _updatePages();
  }

  /// 获取 tree 和 commit 的 sha
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [get-a-branch](https://docs.github.com/zh/rest/branches/branches#get-a-branch),
  /// [create-or-update-file-contents](https://docs.github.com/zh/rest/repos/contents?apiVersion=2022-11-28#create-or-update-file-contents)
  Future<({String commitSha, String treeSha})> _getTreeAndCommitSha() async {
    try {
      // 获取存储库分支 - 可以替代 get ref, get commit
      final options = Options(headers: headers);
      // 结果
      var result = await Deploy.dio.get('$apiUrl/branches/${git.branch}', options: options);
      if (result.statusCode != 200) {
        if (result.statusCode != 404) {
          throw Mistake(message: result.data.toString());
        }
        // 状态码为400时可能是该分支为空, 需要在该分支创建内容
        final data = {"message": "create ${git.branch} branches, and add readme.md", "branch": git.branch, "content": ""};
        result = await Deploy.dio.put('$apiUrl/contents/${"README.md"}', options: options, data: data);
        if (result.statusCode != 200 || result.statusCode != 201) {
          throw Mistake(message: result.data.toString());
        }
      }
      final data = result.data['commit'];
      return (treeSha: (data['commit']?['tree']['sha'] ?? data['tree']['sha']) as String, commitSha: data['sha'] as String);
    } catch (e) {
      throw Mistake(message: '');
    }
  }

  /// 创建文件的 blob sha, 并返回一个 [文件路径 - blob sha] 的映射
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [create-a-blob](https://docs.github.com/zh/rest/git/blobs#create-a-blob)
  Future<TMap<String>> _createBlobSha() async {
    try {
      final options = Options(headers: headers);
      final TMap<String> fileList = {};
      for (var file in FS.getFilesSync(buildDir)) {
        // "index.html": "907d14fb3af2b0d4f18c2d46abe8aedce17367bd"
        var path = FS.relative(file.path, buildDir);
        // 创建 blob, 图片只能转 base64 格式的字符串
        final data = {'content': base64.encode(await file.readAsBytes()), 'encoding': 'base64'};
        // 获取文件的 blob sha
        final result = await Deploy.dio.post('$apiUrl/git/blobs', options: options, data: data);
        fileList[path] = result.data['sha'];
      }
      return fileList;
    } catch (e) {
      throw Mistake(message: '${git.platform} create blob sha failed: \n$e');
    }
  }

  /// 生成 tree, 并返回一个新的 tree sha
  ///
  /// [fileList] 文件路径 - 文件的 blob sha
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [create-a-tree](https://docs.github.com/zh/rest/git/trees?apiVersion=2022-11-28#create-a-tree)
  Future<String> _createTree(TMap<String> fileList, String treeSha) async {
    try {
      // 选项
      final options = Options(headers: headers);
      // 数据
      final data = {
        'base_tree': treeSha,
        'tree': [
          for (var item in fileList.entries)
            {
              'path': item.key,
              'mode': '100644',
              'type': 'blob',
              'sha': item.value,
            },
        ]
      };
      // 生成 tree
      final result = await Deploy.dio.post('$apiUrl/git/trees', options: options, data: data);
      // 创建出现异常
      if (result.statusCode != null && result.statusCode! >= 400) {
        throw Mistake(message: result.data.toString());
      }
      return result.data['sha'] as String;
    } catch (e) {
      throw Mistake(message: '${git.platform} create tree failed: \n$e');
    }
  }

  /// 生成 Commit, 并返回一个 commit sha
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [create-a-commit](https://docs.github.com/zh/rest/git/commits?apiVersion=2022-11-28#create-a-commit)
  Future<String> _generateCommit(String commitSha, String newTreeSha) async {
    try {
      // 选项
      final options = Options(headers: headers);
      // 数据
      final data = {
        'message': 'create a commit of update html site, now the time is ${DateTime.now()}',
        'parents': [commitSha],
        'tree': newTreeSha,
      };
      // 生成 Commit
      var result = await Deploy.dio.post('$apiUrl/git/commits', options: options, data: data);
      // 创建出现异常
      if (result.statusCode != null && result.statusCode! >= 400) {
        throw Mistake(message: result.data.toString());
      }
      return result.data['sha'] as String;
      // 生成 Blob
    } catch (e) {
      throw Mistake(message: '${git.platform.name} generate commit failed: \n$e');
    }
  }

  /// 更新 Ref
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [update-a-reference](https://docs.github.com/zh/rest/git/refs?apiVersion=2022-11-28#update-a-reference)
  Future<void> _updateRef(String newCommitSha) async {
    try {
      // 选项
      final options = Options(headers: headers);
      // 数据
      final data = {'sha': newCommitSha, 'force': true};
      // 更新 Ref
      var result = await Deploy.dio.patch('$apiUrl/git/refs/heads/${git.branch}', options: options, data: data);
      if (result.statusCode != 200) {
        throw Mistake(message: result.data.toString());
      }
    } catch (e) {
      throw Mistake(message: '${git.platform.name} update ref failed: \n$e');
    }
  }

  /// 更新 Github Pages
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// [github pages api](https://docs.github.com/zh/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-pages)
  Future<void> _updatePages() async {
    try {
      // 认证选项
      final options = Options(headers: headers);
      // 获取 GitHub Pages 站点
      var result = await Deploy.dio.get('$apiUrl/pages', options: options);
      // 数据
      var data = {
        'cname': git.cname,
        'source': {'branch': git.branch, 'path': '/'},
      };
      // status == null || statusCode == 404 需要创建站点
      if (result.statusCode == 404) {
        // 创建 GitHub Pages 站点
        await Deploy.dio.post('$apiUrl/pages', data: data, options: options);
        if (result.statusCode != null && result.statusCode! >= 400) {
          throw Mistake(message: result.data.toString());
        }
      } else {
        // 更新有关 GitHub Pages 站点的信息
        result = await Deploy.dio.put('$apiUrl/pages', data: data, options: options);
        if (result.statusCode != null && result.statusCode! >= 400) {
          throw Mistake(message: result.data.toString());
        }
      }
      // 请求 GitHub Pages 构建
      result = await Deploy.dio.post('$apiUrl/pages/builds', options: options);
      if (result.statusCode != 201) {
        throw Mistake(message: result.data.toString());
      }
    } catch (e) {
      throw Mistake(message: 'update ${git.platform.name} pages failed: \n$e');
    }
  }
}


class GiteeDeploy extends GitDeploy {
  GiteeDeploy(super.site);

  // 覆盖创建
  // link [新建文件](https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoContentsPath)
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

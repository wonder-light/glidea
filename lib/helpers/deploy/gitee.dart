import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart' show Options;
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';

import 'deploy.dart';

class GiteeDeploy extends GitDeploy {
  GiteeDeploy(Application site) : super(site, api: null, token: null) {
    final remote = site.remote;
    api = 'https://gitee.com/api/v5/repos/${remote.username}/${remote.repository}';
    token = remote.token;
    headers = {
      'User-Agent': 'Glidea',
      'Content-Type': 'application/json',
    };
  }

  /// 请求头
  late final Map<String, dynamic> headers;

  // 分支的 commit sha
  late final String commitSha;

  static const String _create = 'create';
  static const String _update = 'update';
  static const String _delete = 'delete';

  @override
  Future<void> remoteDetect() async {
    try {
      var params = {'access_token': token};
      // 获取所有分支
      var result = await Deploy.dio.get('$api/branches', queryParameters: params);
      result.checkStateCode();
    } catch (e) {
      throw Mistake.add(message: 'gitee remote detect failed:', hint: Tran.connectFailed, error: e);
    }
  }

  /// 从分支上获取 tree 或 commit 的 sha 信息, 如果分支不存在则创建
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// [获取所有分支](https://help.gitee.com/openapi/v5#tag/repositories/GET/v5/repos/{owner}/{repo}/branches)\
  /// [新建文件](https://help.gitee.com/openapi/v5#tag/repositories/POST/v5/repos/{owner}/{repo}/contents/{path})
  @override
  Future<void> getOrCreateBranches() async {
    try {
      var options = Options(contentType: 'application/x-www-form-urlencoded');
      var params = {'access_token': token};
      // 获取所有分支
      var result = await Deploy.dio.get('$api/branches', queryParameters: params);
      result.checkStateCode();
      // 分支列表
      var branchList = result.data as List<dynamic>;
      // 通过新建文件来创建分支
      if (branchList.isEmpty) {
        // 设置请求体
        var body = {
          'access_token': token,
          'content': '# create'.getBase64(),
          'message': 'create a new file',
          'branch': remote.branch,
        };
        result = await Deploy.dio.post('$api/contents/${"readme.md"}', options: options, data: body);
        // 创建失败
        result.checkStateCode();
        // 设置 commit sha 或 tree sha
        commitSha = result.data['commit']['sha'];
        return;
      }
      // 获取分支的 commit sha
      var branch = branchList.firstWhereOrNull((b) => b['name'] == remote.branch)?['commit']['sha'];
      if (branch is String) {
        commitSha = branch;
        return;
      } else {
        // 没有分支, 测试创建
        var body = {
          'access_token': token,
          'refs': branchList.first['name'],
          'branch_name': remote.branch,
        };
        result = await Deploy.dio.post('$api/branches', options: options, data: body);
        result.checkStateCode();
        Log.i('five');
        // 获取分支的 commit sha
        commitSha = result.data['commit']['sha'];
      }
    } catch (e) {
      throw Mistake.add(message: 'gitee get or create branch failed', hint: Tran.connectFailed, error: e);
    }
  }

  /// 获取远程的所有文件和目录, 如何和本地文件进行比较,
  /// 冰将其标记为 [_create], [_update], [_delete],
  /// 然后将远程与本地合并后推送到远程的管理平台上
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  @override
  Future<void> createCommits() async {
    final updateFiles = await _getBranchTree(commitSha);
    await _commitMultipleFile(updateFiles);
  }

  @override
  Future<void> updatePages() async {
    try {
      var params = {'access_token': token};
      var options = Options(contentType: 'application/x-www-form-urlencoded');
      // 获取 Gitee Pages 站点
      var result = await Deploy.dio.get('$api/pages', queryParameters: params);
      // statusCode == 404 需要创建站点
      if (result.statusCode == 404) {
        // 创建 GitHub Pages 站点
        result = await Deploy.dio.post('$api/pages/builds', data: params, options: options);
        result.checkStateCode();
      } else {
        // 更新有关 Gitee Pages 站点的信息
        var body = {...params, 'domain': remote.domain};
        result = await Deploy.dio.put('$api/pages', data: body, options: options);
        result.checkStateCode();
      }
    } catch (e) {
      throw Mistake.add(message: 'update gitee pages failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 获取分支目录 Tree
  ///
  /// 返回结果为 文件相对路径 - 文件操作类型
  Future<Map<String, String>> _getBranchTree(String treeSha) async {
    try {
      // 例如: { 'README.md': 'update' }
      final Map<String, String> fileMaps = {};
      // 查询参数
      var params = {
        'access_token': token,
        // 赋值为 1, 则递归获取目录
        'recursive': 1,
      };
      // 获取目录 tree
      var result = await Deploy.dio.get('$api/git/trees/$treeSha', queryParameters: params);
      result.checkStateCode();
      // 获取所有文件包括目录, blob 是文件, tree 是目录
      var lists = result.data['tree'] as List;
      // 循环检测哪些需要删除, 哪些需要更新, 哪些需要添加
      for (var item in lists) {
        // 相对目录
        final path = item['path'];
        final absolute = FS.join(buildDir, item['path']);
        // 是文件
        if (FS.fileExistsSync(absolute)) {
          fileMaps[path] = _update; //(action: _update, sha: item['sha']);
        } else if (!FS.dirExistsSync(absolute)) {
          // 将目录排除在 fileMaps 外
          // 文件和目录都不存在, 则删除
          fileMaps[path] = _delete; //(action: _delete, sha: item['sha']);
        }
      }
      // 获取本地中需要添加的文件 - 相对于 [buildDir] 的相对目录
      var filePaths = FS.getFilesSync(buildDir).map((t) => FS.relative(t.path, buildDir)).toSet();
      // 获取未添加的文件路径
      filePaths = filePaths.difference(fileMaps.keys.toSet());
      fileMaps.addAll({
        for (var item in filePaths) item: _create, //(action: _create, sha: null)
      });
      // 返回
      return fileMaps;
    } catch (e) {
      throw Mistake.add(message: 'get gitee branch tree failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 提交多个文件变更
  Future<void> _commitMultipleFile(Map<String, String> updateFiles) async {
    try {
      final options = Options(headers: headers, contentType: 'application/json');
      // delete => action, path
      // update => action, path, encoding, content
      // create => action, path, encoding, content
      var body = {
        'access_token': token,
        'branch': remote.branch,
        'message': 'create a commit of update site, now the time is ${DateTime.now()}',
        'actions': [
          for (var MapEntry(:key, :value) in updateFiles.entries)
            {
              'path': key,
              'action': value,
              if (value != _delete) 'encoding': 'base64',
              if (value != _delete) 'content': await FS.readAsBase64(FS.join(buildDir, key)),
            },
        ],
      };
      var result = await Deploy.dio.post('$api/commits', options: options, data: body);
      result.checkStateCode();
    } catch (e) {
      throw Mistake.add(message: 'commit multiple file failed: ', hint: Tran.connectFailed, error: e);
    }
  }
}

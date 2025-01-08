import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart' show Options;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';

import 'deploy.dart';

class GiteeDeploy extends GitDeploy {
  GiteeDeploy(Application site) : super(site, api: null, token: null) {
    final remote = site.remote.gitee;
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

  /// 分支
  String get branch => remote.gitee.branch;

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
          'branch': branch,
        };
        result = await Deploy.dio.post('$api/contents/${"readme.md"}', options: options, data: body);
        // 创建失败
        result.checkStateCode();
        // 设置 commit sha 或 tree sha
        commitSha = result.data['commit']['sha'];
        return;
      }
      // 获取分支的 commit sha
      var bran = branchList.firstWhereOrNull((b) => b['name'] == branch)?['commit']['sha'];
      if (bran is String) {
        commitSha = bran;
        return;
      } else {
        // 没有分支, 测试创建
        var body = {
          'access_token': token,
          'refs': branchList.first['name'],
          'branch_name': branch,
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

  /// 获取分支目录 Tree, 并与本地文件进行比较, 获取需要更新或删除的文件和操作
  ///
  /// 返回值是一个键值对, key: 相对路径, value: create - 创建, update - 更新, delete - 删除
  Future<Map<String, ActionType>> _getBranchTree(String treeSha) async {
    try {
      // 查询参数
      var params = {
        'access_token': token,
        // 赋值为 1, 则递归获取目录
        'recursive': 1,
      };
      // 获取目录 tree
      var result = await Deploy.dio.get('$api/git/trees/$treeSha', queryParameters: params);
      result.checkStateCode();
      // 例如: { 'README.md': 'update' }
      final Map<String, ActionType> fileLists = {};
      // 记录的路径
      final Set<String> filePaths = {};
      // 获取需要更新和输出的文件路径和 sha
      for (var tree in (result.data['tree'] as List)) {
        // 检查文件
        if (tree['type'] != 'blob') continue;
        final path = tree['path'];
        final absolute = FS.join(buildDir, path);
        filePaths.add(path);
        // 不存在的要删除
        if (!FS.fileExistsSync(absolute)) {
          fileLists[path] = ActionType.delete;
        } else if (tree['sha'] != await getFileBlobSha(absolute)) {
          // 比较 sha, 不同则要更新
          fileLists[path] = ActionType.update;
        }
      }
      // 添加远程中没有的本地的文件
      final diff = FS.getFilesSync(buildDir).map((t) => FS.relative(t.path, buildDir)).toSet().difference(filePaths);
      fileLists.addAll({for (var item in diff) item: ActionType.create});
      // 返回
      return fileLists;
    } catch (e) {
      throw Mistake.add(message: 'get gitee branch tree failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 提交多个文件变更
  Future<void> _commitMultipleFile(Map<String, ActionType> updateFiles) async {
    try {
      final options = Options(headers: headers, contentType: 'application/json');
      // delete => action, path
      // update => action, path, encoding, content
      // create => action, path, encoding, content
      var body = {
        'access_token': token,
        'branch': branch,
        'message': 'create a commit of update site, now the time is ${DateTime.now()}',
        'actions': [
          for (var MapEntry(:key, :value) in updateFiles.entries)
            {
              'path': key,
              'action': value.name,
              if (value != ActionType.delete) 'encoding': 'base64',
              if (value != ActionType.delete) 'content': await FS.readAsBase64(FS.join(buildDir, key)),
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

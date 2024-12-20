import 'package:dio/dio.dart' show Options;
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';

import 'deploy.dart';

/// Github 部署, 包括 github、gitee、coding TODO: 测试令牌需要的权限
///
/// 更多请查看详情 [github API git](https://docs.github.com/zh/rest/authentication/endpoints-available-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#git)
class GithubDeploy extends GitDeploy {
  GithubDeploy(Application site) : super(site, api: null, token: null) {
    api = 'https://api.github.com/repos/${site.remote.username}/${site.remote.repository}';
    token = 'Bearer ${site.remote.token}';
    headers = {
      'User-Agent': 'Glidea',
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer ${site.remote.token}',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json',
    };
  }

  /// 请求头
  late final Map<String, dynamic> headers;

  late ({String commitSha, String treeSha}) _branchInfo;

  @override
  Future<void> remoteDetect() async {
    try {
      // 检测仓库是否存在
      final result = await Deploy.dio.get(api);
      result.checkStateCode();
    } catch (e) {
      throw Mistake.add(message: 'github remote detect failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 从分支上获取 tree 和 commit 的 sha 信息, 如果分支不存在则创建
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// [get-a-branch](https://docs.github.com/zh/rest/branches/branches#get-a-branch)\
  /// [create-or-update-file-contents](https://docs.github.com/zh/rest/repos/contents?apiVersion=2022-11-28#create-or-update-file-contents)
  @override
  Future<void> getOrCreateBranches() async {
    try {
      // 获取存储库分支 - 可以替代 get ref, get commit
      final options = Options(headers: headers);
      // 结果
      var result = await Deploy.dio.get('$api/branches/${remote.branch}', options: options);
      if (result.statusCode == 404) {
        // 状态码为400时可能是该分支为空, 需要在该分支创建内容
        final data = {"message": "create ${remote.branch} branches, and add readme.md", "branch": remote.branch, "content": ""};
        result = await Deploy.dio.put('$api/contents/${"README.md"}', options: options, data: data);
      }
      result.checkStateCode();
      final data = result.data['commit'];
      // 获取信息
      _branchInfo = (
        treeSha: (data['commit']?['tree']['sha'] ?? data['tree']['sha']) as String,
        commitSha: data['sha'] as String,
      );
    } catch (e) {
      throw Mistake.add(message: '', hint: Tran.connectFailed, error: e);
    }
  }

  @override
  Future<void> createCommits() async {
    final changes = await _getLocalChangeBlob(_branchInfo.treeSha);
    final fileSha = await _createBlobSha(changes);
    final newTreeSha = await _createTree(fileSha, _branchInfo.treeSha);
    final newCommitSha = await _generateCommit(_branchInfo.commitSha, newTreeSha);
    await _updateRef(newCommitSha);
  }

  /// 更新 Github Pages
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// [github pages api](https://docs.github.com/zh/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#repository-permissions-for-pages)
  @override
  Future<void> updatePages() async {
    try {
      // 认证选项
      final options = Options(headers: headers);
      // 获取 GitHub Pages 站点
      var result = await Deploy.dio.get('$api/pages', options: options);
      // 数据
      var data = {
        'cname': remote.cname,
        'source': {'branch': remote.branch, 'path': '/'},
      };
      // statusCode == 404 需要创建站点
      if (result.statusCode == 404) {
        // 创建 GitHub Pages 站点
        result = await Deploy.dio.post('$api/pages', data: data, options: options);
        result.checkStateCode();
      } else {
        // 更新有关 GitHub Pages 站点的信息
        result = await Deploy.dio.put('$api/pages', data: data, options: options);
        result.checkStateCode();
      }
      // 请求 GitHub Pages 构建
      result = await Deploy.dio.post('$api/pages/builds', options: options);
      result.checkStateCode();
    } catch (e) {
      throw Mistake.add(message: 'update github pages failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 获取本地需要更新的文件, 已经远程需要输出的文件
  ///
  /// 返回值是一个键值对, key: 相对路径, value: true - 需要更新, false - 需要删除
  Future<Map<String, bool>> _getLocalChangeBlob(String treeSha) async {
    try {
      // 选项
      final options = Options(headers: headers);
      // 获取 Get a tree
      var result = await Deploy.dio.get('$api/git/trees/$treeSha?recursive=1', options: options);
      result.checkStateCode();
      final Map<String, bool> fileLists = {};
      // 获取需要更新和输出的文件路径和 sha
      for (var tree in (result.data['tree'] as List)) {
        // 检查文件
        if (tree['type'] != 'blob') continue;
        final path = tree['path'];
        final absolute = FS.join(buildDir, path);
        // 不存在的要删除
        if (!FS.fileExistsSync(absolute)) {
          fileLists[path] = false;
        } else if (tree['sha'] != await getFileBlobSha(absolute)) {
          // 比较 sha, 不同则要更新
          fileLists[path] = true;
        }
      }
      // 添加远程中没有的本地的文件
      final diff = FS.getFilesSync(buildDir).map((t) => FS.relative(t.path, buildDir)).toSet().difference(fileLists.keys.toSet());
      fileLists.addAll({for (var item in diff) item: true});
      // 返回
      return fileLists;
    } catch (e) {
      throw Mistake.add(message: 'get local change blob failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 创建文件的 blob sha, 并返回一个 [文件路径 - blob sha] 的映射
  ///
  /// [fileLists] 使用 [_getLocalChangeBlob] 的返回结果
  ///
  /// 返回值是一个键值对, key: 相对路径, value: 文件的 sha 值, 为 null 时删除文件
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [create-a-blob](https://docs.github.com/zh/rest/git/blobs#create-a-blob)
  Future<TMap<String?>> _createBlobSha(Map<String, bool> fileLists) async {
    try {
      final options = Options(headers: headers);
      // 文件相对路径 - 文件 blob sha
      final TMap<String?> fileShaLists = {};
      for (var MapEntry(:key, :value) in fileLists.entries) {
        // false: 需要删除, 将 sha 设置为 null 即可
        if (!value) {
          fileShaLists[key] = null;
          continue;
        }
        // ture: 需要添加
        // 创建 blob, 图片只能转 base64 格式的字符串
        final data = {'content': await FS.readAsBase64(FS.join(buildDir, key)), 'encoding': 'base64'};
        // 获取文件的 blob sha
        final result = await Deploy.dio.post('$api/git/blobs', options: options, data: data);
        fileShaLists[key] = result.data['sha'];
      }
      return fileShaLists;
    } catch (e) {
      throw Mistake.add(message: 'github create blob sha failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 生成 tree, 并返回一个新的 tree sha
  ///
  /// [fileList] 文件路径 - 文件的 blob sha
  ///
  /// 出现错误时抛出 [Mistake] 异常类
  ///
  /// link: [create-a-tree](https://docs.github.com/zh/rest/git/trees?apiVersion=2022-11-28#create-a-tree)
  Future<String> _createTree(TMap<String?> fileList, String treeSha) async {
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
      var result = await Deploy.dio.post('$api/git/trees', options: options, data: data);
      // 创建出现异常
      result.checkStateCode();
      return result.data['sha'] as String;
    } catch (e) {
      throw Mistake.add(message: 'github create tree failed: ', hint: Tran.connectFailed, error: e);
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
        'message': 'create a commit of update site, now the time is ${DateTime.now()}',
        'parents': [commitSha],
        'tree': newTreeSha,
      };
      // 生成 Commit
      var result = await Deploy.dio.post('$api/git/commits', options: options, data: data);
      // 创建出现异常
      result.checkStateCode();
      return result.data['sha'] as String;
      // 生成 Blob
    } catch (e) {
      throw Mistake.add(message: '${remote.platform.name} generate commit failed: ', hint: Tran.connectFailed, error: e);
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
      var result = await Deploy.dio.patch('$api/git/refs/heads/${remote.branch}', options: options, data: data);
      result.checkStateCode();
    } catch (e) {
      throw Mistake.add(message: '${remote.platform.name} update ref failed: ', hint: Tran.connectFailed, error: e);
    }
  }
}

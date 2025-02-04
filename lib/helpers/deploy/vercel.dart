part of 'deploy.dart';

/// Vercel 部署
class VercelDeploy extends NetlifyDeploy {
  VercelDeploy({
    required super.remote,
    super.appDir,
    super.buildDir,
    super.api = 'https://api.vercel.com',
    String? token,
    String? siteId,
  }) : super(token: token ?? 'Bearer ${remote.vercel.accessToken}', siteId: siteId ?? remote.vercel.siteId) {
    //token = 'Bearer wGlDPIxkkXSrfAgehnQEx1QJ';
  }

  /// 文件哈希集合
  ///
  ///       {
  ///         '/index.html': 'sha',
  ///       }
  TMap<String> fileHash = {};

  @override
  Future<void> remoteDetect() async {
    final result = await Deploy.dio.get('$api/v6/deployments?projectId=$siteId', options: Options(headers: header));
    result.checkStateCode();
  }

  @override
  Future<void> publish() async {
    await super.publish();
    await deployment();
  }

  @override
  Future<List<String>> requestFiles(TMap<String> fileList) async {
    fileHash = Map.of(fileList);
    final options = Options(headers: header);
    // 获取最新的部署
    var result = await Deploy.dio.get('$api/v6/deployments?projectId=$siteId', options: options);
    result.checkStateCode();
    final deployments = result.data['deployments'] as List;
    if (deployments.isEmpty) {
      return fileList.keys.toList();
    }
    // 部署 ID
    deployId = deployments.first['uid'];
    result = await Deploy.dio.get('$api/v6/deployments/$deployId/files', options: options);
    result.checkStateCode();
    // 文件 + 文件夹的数据
    final items = result.data[0]['children'] as List;
    // 检查 file 路径 和 hash
    void checkItem(String path, List items) {
      for (var item in items) {
        final srcPath = '$path/${item['name']}';
        if (item['children'] case List children when children.isNotEmpty && item['type'] == 'directory') {
          checkItem(srcPath, children);
        } else if (item['type'] == 'file' && fileList[srcPath] == item['uid']) {
          fileList.remove(srcPath);
        }
      }
    }

    // 更新 fileList
    checkItem('', items);
    return fileList.keys.toList();
  }

  @override
  Future<Response> uploadFile(String filePath) async {
    final fileContent = await File(FS.join(buildDir, filePath)).readAsBytes();
    final options = Options(headers: {...header, 'x-vercel-digest': fileHash[filePath], 'Content-Type': 'application/octet-stream'});
    return await Deploy.dio.post('$api/v2/files', options: options, data: fileContent);
  }

  /// 进行部署
  Future<void> deployment() async {
    final data = {
      'name': siteId,
      'files': [
        for (var MapEntry(:key, :value) in fileHash.entries)
          {
            'file': key.startsWith('/') ? key.substring(1) : key,
            'sha': value,
          }
      ]
    };
    final result = await Deploy.dio.post('$api/v13/deployments', options: Options(headers: header), data: data);
    result.checkStateCode();
  }
}

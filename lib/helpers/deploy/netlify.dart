﻿part of 'deploy.dart';

/// Netlify 部署
class NetlifyDeploy extends Deploy {
  NetlifyDeploy({
    required super.remote,
    super.appDir,
    super.buildDir,
    super.api = 'https://api.netlify.com/api/v1',
    String? token,
    String? siteId,
  }) : super(token: token ?? 'Bearer ${remote.netlify.accessToken}') {
    this.siteId = siteId ?? remote.netlify.siteId;
    header = {
      'User-Agent': 'Glidea',
      'Authorization': token,
    };
  }

  /// Netflix ID
  late final String siteId;

  /// 请求头
  late final Map<String, dynamic> header;

  /// 部署的 id
  late String deployId = '';

  @override
  Future<void> publish() async {
    // 详情请看
    // https://docs.netlify.com/api/get-started/#deploy-with-the-api
    final fileList = await prepareLocalFilesList();
    // 需要上传的文件的哈希值
    final hashOfFilesToUpload = await requestFiles(fileList);
    // 开始上传
    for (var filePath in hashOfFilesToUpload) {
      // 出错时尝试两次
      try {
        var result = await uploadFile(filePath);
        result.checkStateCode();
      } catch (e) {
        var result = await uploadFile(filePath);
        result.checkStateCode();
      }
    }
  }

  @override
  Future<void> remoteDetect() async {
    final result = await Deploy.dio.get('$api/sites/$siteId', options: Options(headers: header));
    result.checkStateCode();
  }

  /// 准备本地文件列表
  ///
  /// throw [Exception] exception
  ///
  ///       {
  ///         '/index.html': 'sha',
  ///       }
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
  /// throw [Exception] exception
  Future<List<String>> requestFiles(TMap<String> fileList) async {
    final options = Options(headers: header);
    final data = {'files': fileList};
    final result = await Deploy.dio.post('$api/sites/$siteId/deploys', data: data, options: options);
    // 设置 _deployId
    deployId = result.data['id'];
    List<String> lists = (result.data['required'] as List).cast<String>();
    // "/index.html": "907d14fb3af2b0d4f18c2d46abe8aedce17367bd" =>
    // "907d14fb3af2b0d4f18c2d46abe8aedce17367bd": "/index.html"
    fileList = fileList.map((k, v) => MapEntry(v, k));
    // 获取对应的路径
    return lists.map((item) => fileList[item]!).toList();
  }

  /// 上传文件
  Future<Response> uploadFile(String filePath) async {
    final options = Options(headers: {...header, 'Content-Type': 'application/octet-stream'});
    final fileContent = await File(FS.join(buildDir, filePath)).readAsBytes();
    // 上传
    return await Deploy.dio.put('$api/deploys/$deployId/files$filePath', data: fileContent, options: options);
  }
}

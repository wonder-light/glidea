part of 'deploy.dart';

/// SFTP 部署
class SftpDeploy extends Deploy {
  SftpDeploy({required super.remote, super.appDir, super.buildDir});

  @override
  Future<void> remoteDetect() async {
    final client = await getSftpClient();
    final ftp = await client.sftp();
    await ftp.absolute('/');
    client.close();
  }

  @override
  Future<void> publish() async {
    var remotePath = remote.sftp.remotePath;
    if (remotePath.trim().isEmpty) remotePath = '/';
    final client = await getSftpClient();
    final ftp = await client.sftp();
    await ftp.uploadDirectory(buildDir, remotePath);
    client.close();
  }

  /// 获取 FTP 客户端
  Future<SSHClient> getSftpClient() async {
    final sftp = remote.sftp;
    final client = SSHClient(
      await SSHSocket.connect(sftp.server, int.parse(sftp.port)),
      username: sftp.username,
      onPasswordRequest: () => sftp.password,
    );
    return client;
  }
}

extension SftpClientExt on SftpClient {
  /// 上传目录
  Future<void> uploadDirectory(String localDir, String remoteDir) async {
    if (remoteDir.trim().isEmpty) {
      remoteDir = '/';
    }
    for (var entry in FS.getEntitySync(localDir)) {
      // 需要以 / 开头
      final path = FS.join(remoteDir, FS.relative(entry.path, localDir));
      if (entry case File file) {
        final remoteFile = await open(path, mode: SftpFileOpenMode.create | SftpFileOpenMode.truncate | SftpFileOpenMode.write);
        await remoteFile.writeBytes(await file.readAsBytes());
      } else if (entry is Directory) {
        await mkdir(path);
      }
    }
  }
}

import 'dart:io' show Directory, File;

import 'package:dartssh2/dartssh2.dart' show SSHClient, SSHSocket, SftpClient, SftpFileOpenMode;
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/lang/base.dart';

import 'deploy.dart';

/// SFTP 部署
class SftpDeploy extends Deploy {
  SftpDeploy(super.site, {super.api = ''});

  @override
  Future<void> remoteDetect() async {
    try {
      final client = await getSftpClient();
      final ftp = await client.sftp();
      await ftp.absolute('/');
      client.close();
    } catch (e) {
      throw Mistake.add(message: 'sftp remote detect failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  @override
  Future<void> publish() async {
    try {
      var remotePath = remote.remotePath;
      if (remotePath.trim().isEmpty) remotePath = '/';
      final client = await getSftpClient();
      final ftp = await client.sftp();
      await ftp.uploadDirectory(buildDir, remotePath);
      client.close();
    } catch (e) {
      throw Mistake.add(message: 'sftp publish failed: ', hint: Tran.connectFailed, error: e);
    }
  }

  /// 获取 FTP 客户端
  Future<SSHClient> getSftpClient() async {
    final client = SSHClient(
      await SSHSocket.connect(remote.server, int.parse(remote.port)),
      username: remote.username,
      onPasswordRequest: () => remote.password,
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

import 'deploy.dart';

/// SFTP 部署
class SftpDeploy extends Deploy {
  SftpDeploy(super.site, {super.api = ''});

  @override
  Future<void> publish() async {
    // TODO: implement publish
    throw UnimplementedError();
  }
}

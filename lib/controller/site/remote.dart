part of 'site.dart';

/// 混合 - 远程
mixin RemoteSite on DataProcess, ThemeSite {
  /// 发布的网址
  String get domain => state.remote.domain;

  /// 远程
  RemoteSetting get remote => state.remote;

  /// 评论
  CommentSetting get comment => state.comment;

  /// 检测是否可以进行发布
  ///
  /// [true] - 可以进行发布
  bool get checkPublish {
    return switch (remote.platform) {
      DeployPlatform.github => _isCheckGitPublish(remote.github),
      DeployPlatform.gitee => _isCheckGitPublish(remote.gitee),
      DeployPlatform.coding => _isCheckGitPublish(remote.coding),
      DeployPlatform.sftp => _isCheckSftpPublish(),
      DeployPlatform.netlify => _isCheckNetlifyPublish(),
    };
  }

  /// 发布站点
  Future<Notif> publishSite() async {
    try {
      // 检测主题是否有效
      if (!selectThemeValid) {
        Get.error(Tran.noValidCurrentTheme);
        return Notif(hint: Tran.noValidCurrentTheme);
      }
      // 检测是否可以发布
      if (!checkPublish) {
        Get.error(Tran.syncWarning);
        return Notif(hint: Tran.syncWarning);
      }
      // 在后台进行发布
      await Background.instance.publishSite(state);
      // 成功
      Get.success(Tran.syncSuccess);
      return Notif(hint: Tran.syncSuccess);
    } catch (e, s) {
      Log.i('publish site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.syncError1);
    }
  }

  /// 预览站点
  Future<Notif> previewSite() async {
    try {
      if (!selectThemeValid) {
        return Notif(hint: Tran.noValidCurrentTheme);
      }
      // 在后台进行操作
      await Background.instance.previewSite(state);
      // 成功
      return Notif(hint: Tran.renderSuccess);
    } catch (e, s) {
      Log.e('preview site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.renderError);
    }
  }

  /// 更新远程配置
  Future<bool> updateRemoteConfig({TJsonMap remotes = const {}, TJsonMap comments = const {}}) async {
    try {
      // 保存数据
      await saveSiteData(callback: () async {
        // 远程
        state.remote = state.remote.copyWith<RemoteSetting>(remotes)!;
        // 合并
        state.comment = state.comment.copyWith<CommentSetting>(comments)!;
      });
      return true;
    } catch (e, s) {
      Log.e('remote detect failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 远程检测
  Future<bool> remoteDetect() async {
    try {
      await Background.instance.remoteDetect(state.remote, state.appDir, state.buildDir);
      return true;
    } catch (e, s) {
      Log.e('remote detect failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 检测 github, gitee, coding
  bool _isCheckGitPublish(RemoteGithub github) {
    return github.username.isNotEmpty && github.branch.isNotEmpty && remote.domain.isNotEmpty && github.token.isNotEmpty && github.repository.isNotEmpty;
  }

  /// 检测 sftp
  bool _isCheckSftpPublish() {
    final sftp = remote.sftp;
    return sftp.port.isNotEmpty && sftp.server.isNotEmpty && sftp.username.isNotEmpty && sftp.password.isNotEmpty;
  }

  /// 检测 netlify
  bool _isCheckNetlifyPublish() {
    final netlify = remote.netlify;
    return netlify.siteId.isNotEmpty && netlify.accessToken.isNotEmpty;
  }
}

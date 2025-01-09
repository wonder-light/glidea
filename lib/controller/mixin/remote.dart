import 'dart:io' show HttpServer;

import 'package:get/get.dart' show BoolExtension, Get, StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/deploy/deploy.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/render/render.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/setting.dart';
import 'package:shelf/shelf_io.dart' as shelf_io show serve;
import 'package:shelf_static/shelf_static.dart' show createStaticHandler;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

/// 混合 - 远程
mixin RemoteSite on StateController<Application>, DataProcess, ThemeSite {
  /// 发布的网址
  String get domain => state.remote.domain;

  /// 是否这正在同步中
  final inBeingSync = false.obs;

  /// 正在进行远程检测中
  final inRemoteDetect = false.obs;

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

  /// 今天文件服务
  HttpServer? fileServer;

  @override
  Future<void> disposeState() async {
    inBeingSync.dispose();
    inRemoteDetect.dispose();
    await fileServer?.close(force: true);
    await super.disposeState();
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
      // 设置同步中
      inBeingSync.value = true;
      // 设置域名
      state.themeConfig.domain = state.remote.domain;
      // render
      await renderAll();
      await Deploy.create(state).publish();
      // 成功
      Get.success(Tran.syncSuccess);
      return Notif(hint: Tran.syncSuccess);
    } catch (e, s) {
      Log.i('publish site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.syncError1);
    } finally {
      inBeingSync.value = false;
    }
  }

  /// 预览站点
  Future<Notif> previewSite() async {
    try {
      if (!selectThemeValid) {
        return Notif(hint: Tran.noValidCurrentTheme);
      }
      // 设置域名
      state.themeConfig.domain = 'http://localhost:${state.previewPort}';
      await renderAll();
      // 启动静态文件服务
      await _enableStaticServer();
      // 成功
      return Notif(hint: Tran.renderSuccess);
    } catch (e, s) {
      fileServer?.close(force: true);
      fileServer = null;
      Log.e('preview site failed', error: e, stackTrace: s);
      return Notif(hint: Tran.renderError);
    }
  }

  /// 渲染所有
  ///
  /// 当构建失败时抛出 [Exception] 错误
  Future<void> renderAll() async {
    final render = RemoteRender(site: state);
    await render.clearOutputFolder();
    await render.formatDataForRender();
    await render.copyFiles();
    await render.buildTemplate();
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
      // 设置正在检测中
      inRemoteDetect.value = true;
      state.themeConfig.domain = state.remote.domain;
      await Deploy.create(state).remoteDetect();
      return true;
    } catch (e, s) {
      Log.e('remote detect failed', error: e, stackTrace: s);
      return false;
    } finally {
      // 检测完毕
      inRemoteDetect.value = false;
    }
  }

  /// 启动静态文件服务器
  ///
  /// 出错时抛出 [Exception] 异常
  Future<void> _enableStaticServer() async {
    if (fileServer == null) {
      // 启动服务
      var handler = createStaticHandler(state.buildDir, defaultDocument: 'index.html');
      fileServer = await shelf_io.serve(handler, 'localhost', state.previewPort, shared: true);
    }
    // 打开网址
    await launchUrlString(state.themeConfig.domain);
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

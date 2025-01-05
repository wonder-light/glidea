import 'dart:io' show HttpServer;

import 'package:get/get.dart' show BoolExtension, Get, StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/deploy/deploy.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/render/render.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';
import 'package:shelf/shelf_io.dart' as shelf_io show serve;
import 'package:shelf_static/shelf_static.dart' show createStaticHandler;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

/// 混合 - 远程
mixin RemoteSite on StateController<Application>, DataProcess, ThemeSite {
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
      DeployPlatform.github => _isCheckGitPublish(remote),
      DeployPlatform.gitee => _isCheckGitPublish(remote),
      DeployPlatform.coding => _isCheckGitPublish(remote),
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
  Future<void> publishSite() async {
    // 检测主题是否有效
    if (!selectThemeValid) {
      Get.error(Tran.noValidCurrentTheme);
      return;
    }
    // 检测是否可以发布
    if (!checkPublish) {
      Get.error(Tran.syncWarning);
      return;
    }
    try {
      // 设置同步中
      inBeingSync.value = true;
      // 设置域名
      state.themeConfig.domain = state.remote.domain;
      // render
      await renderAll();
      await Deploy.create(state).publish();
      // 成功
      Get.success(Tran.syncSuccess);
    } on Mistake catch (e, s) {
      Log.i('$e\n$s');
      Get.error(e.hint.isEmpty ? Tran.syncError1 : e.hint);
    } finally {
      inBeingSync.value = false;
    }
  }

  /// 预览站点
  Future<void> previewSite() async {
    if (!selectThemeValid) {
      Get.error(Tran.noValidCurrentTheme);
      return;
    }
    try {
      // 设置域名
      state.themeConfig.domain = 'http://localhost:${state.previewPort}';
      await renderAll();
      // 启动静态文件服务
      await _enableStaticServer();
      // 成功
      Get.success(Tran.renderSuccess);
    } on Mistake catch (e) {
      Log.i(e);
      Get.error(e.hint);
    }
  }

  /// 渲染所有
  ///
  /// 当构建失败时抛出 [Mistake] 错误
  Future<void> renderAll() async {
    final render = RemoteRender(site: state);
    await render.clearOutputFolder();
    await render.formatDataForRender();
    await render.copyFiles();
    await render.buildTemplate();
  }

  /// 更新远程配置
  Future<void> updateRemoteConfig({List<ConfigBase> remotes = const [], List<ConfigBase> comments = const []}) async {
    // 保存数据
    await saveSiteData(callback: () async {
      try {
        // 远程
        TJsonMap items = {for (var config in remotes) config.name: config.value};
        state.remote = state.remote.copyWith<RemoteSetting>(items)!;
        // 评论
        items = {for (var config in comments) config.name: config.value};
        // 合并
        state.comment = state.comment.copyWith<CommentSetting>({
          if (items['commentPlatform'] case String value) 'commentPlatform': value,
          if (items['showComment'] case bool value) 'showComment': value,
          'disqusSetting': items,
          'gitalkSetting': items,
        })!;
      } catch (e) {
        throw Mistake(message: 'RemoteSite.updateRemoteConfig save remote config failed: \n$e');
      }
    });
    // 通知
    Get.success(Tran.themeConfigSaved);
  }

  /// 远程检测
  Future<void> remoteDetect() async {
    try {
      if (!checkPublish) return;
      // 设置正在检测中
      inRemoteDetect.value = true;
      state.themeConfig.domain = state.remote.domain;
      await Deploy.create(state).remoteDetect();
      // 成功通知
      Get.success(Tran.connectSuccess);
      // 检测完毕
      inRemoteDetect.value = false;
    } on Mistake catch (e) {
      Log.w(e);
      // 检测完毕
      inRemoteDetect.value = false;
      // 失败通知
      Get.error(Tran.connectFailed);
    }
  }

  /// 启动静态文件服务器
  Future<void> _enableStaticServer() async {
    try {
      if (fileServer == null) {
        // 启动服务
        var handler = createStaticHandler(state.buildDir, defaultDocument: 'index.html');
        fileServer = await shelf_io.serve(handler, 'localhost', state.previewPort, shared: true);
      }
      // 打开网址
      await launchUrlString(state.themeConfig.domain);
    } catch (e) {
      fileServer?.close(force: true);
      fileServer = null;
      throw Mistake(message: 'enable static server failed: \n$e', hint: 'renderError');
    }
  }

  /// 检测 github, gitee, coding
  bool _isCheckGitPublish(RemoteGithub github) {
    return github.username.isNotEmpty && github.branch.isNotEmpty && remote.domain.isNotEmpty && github.token.isNotEmpty && github.repository.isNotEmpty;
  }

  /// 检测 sftp
  bool _isCheckSftpPublish() {
    final sftp = remote;
    return sftp.port.isNotEmpty && sftp.server.isNotEmpty && sftp.username.isNotEmpty && sftp.password.isNotEmpty;
  }

  /// 检测 netlify
  bool _isCheckNetlifyPublish() {
    final netlify = remote;
    return netlify.netlifySiteId.isNotEmpty && netlify.netlifyAccessToken.isNotEmpty;
  }
}

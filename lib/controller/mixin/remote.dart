import 'dart:convert' show utf8;
import 'dart:io' show HttpServer, Process, ProcessStartMode;

import 'package:get/get.dart' show BoolExtension, Get, StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/deploy/deploy.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';
import 'package:glidea/models/tag.dart';
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
    final remote = state.remote;
    return switch (remote.platform) {
      DeployPlatform.github ||
      DeployPlatform.gitee ||
      DeployPlatform.coding =>
        remote.username.isNotEmpty && remote.branch.isNotEmpty && remote.domain.isNotEmpty && remote.token.isNotEmpty && remote.repository.isNotEmpty,
      DeployPlatform.sftp => remote.port.isNotEmpty && remote.server.isNotEmpty && remote.username.isNotEmpty && remote.password.isNotEmpty,
      DeployPlatform.netlify => remote.netlifySiteId.isNotEmpty && remote.netlifyAccessToken.isNotEmpty,
    };
  }

  /// 匹配 feature 本地图片路径的正则
  ///
  /// r'file.*/post-images/'
  RegExp get featureReg => RegExp(r'(file)?.*/post-images/');

  /// 渲染 post 的数据
  List<PostRender> _postsData = [];

  /// 渲染 tag 的数据
  List<TagRender> _tagsData = [];
  Map<String, TagRender> _tagsMap = {};

  /// 菜单数据
  List<Menu> _menusData = [];

  /// 当前主题路径
  String _themePath = '';

  /// 今天文件服务
  HttpServer? fileServer;

  @override
  Future<void> disposeState() async {
    inBeingSync.dispose();
    inRemoteDetect.dispose();
    await fileServer?.close(force: true);
    return super.disposeState();
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
    _themePath = FS.join(state.appDir, 'themes', state.themeConfig.selectTheme);
    await _clearOutputFolder();
    await _formatDataForRender();
    await _buildHtmlTemplate();
    await _copyFiles();
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

  /// 清理输出目录
  Future<void> _clearOutputFolder() async {
    try {
      FS.deleteDirSync(state.buildDir);
      FS.createDirSync(state.buildDir);
    } catch (e) {
      throw Mistake(message: 'clear output folder failed: \n$e', hint: 'renderError');
    }
  }

  /// 为呈现页面格式化数据
  Future<void> _formatDataForRender() async {
    try {
      // 标签
      _tagsData = state.tags.map(_tagToRender).toList();
      // 标签 slug - 对象
      _tagsMap = {
        for (var item in _tagsData) item.slug: item,
      };
    } catch (e) {
      throw Mistake(message: 'format Tag to TagRender error: \n$e', hint: 'renderError');
    }
    try {
      // 已经发布的 post
      var publishPost = state.posts.where(_filterPublishPost);
      // post 数据
      _postsData = publishPost.map(_postToRender).toList();
      // 对 post 进行排序, 置顶优先, 其次新发布的在前
      // compareFn(a, b) 返回值    排序顺序
      //  > 0	                    a 在 b 后，如 [b, a]
      //  < 0	                    a 在 b 前，如 [a, b]
      //  === 0	                  保持 a 和 b 原来的顺序
      _postsData.sort((prev, next) {
        int com = (next.isTop ? 1 : 0) - (prev.isTop ? 1 : 0);
        if (com != 0) return com;
        com = next.date.compareTo(prev.date);
        return com;
      });
    } catch (e) {
      throw Mistake(message: 'format Post to PostRender error: \n$e', hint: 'renderError');
    }
    try {
      // 菜单数据
      _menusData = state.menus.map((m) => m.copy<Menu>()!).toList();
    } catch (e) {
      throw Mistake(message: 'format Menu data error: \n$e', hint: 'renderError');
    }
  }

  /// 构建 HTML 模板
  Future<void> _buildHtmlTemplate() async {
    // 渲染数据路径
    final renderDataPath = FS.join(state.supportDir, 'render_data.json');
    try {
      // 渲染数据
      final data = {
        'posts': _postsData,
        'tags': _tagsData,
        'menus': _menusData,
        'themeConfig': themeConfig,
        'customConfig': themeCustomConfig,
        'commentSetting': state.comment,
        'utils': {},
        'isHomepage': false,
        'appDir': state.appDir,
        'buildDir': state.buildDir,
        'minify': true,
      };
      await FS.writeString(renderDataPath, data.toJson());
    } catch (e) {
      throw Mistake(message: 'build template’s render data failed: \n$e', hint: 'renderError');
    }
    // 通信 node
    try {
      // 目标路径  TODO: 目前只在 Windows 平台使用, 且需要有 node 环境
      var targetPath = FS.join(state.supportDir, 'js');
      // 解压缩
      await FS.unzip('assets/public/js.zip', targetPath, isAsset: true, cover: true);
      // js 路径
      targetPath = FS.join(targetPath, 'index.js');
      var pro = await Process.start('node', [targetPath, renderDataPath], mode: ProcessStartMode.normal);
      // 获取输出
      for (var item in await pro.stdout.transform(utf8.decoder).toList()) {
        Log.i(item);
      }
      // 等待退出
      await pro.exitCode;
    } catch (e) {
      throw Mistake(message: 'start node process failed: \n$e', hint: 'renderError');
    }
  }

  /// 复制文件
  Future<void> _copyFiles() async {
    try {
      final items = {
        (input: 'post-images', output: 'post-images', isThemePath: false),
        (input: 'images', output: 'images', isThemePath: false),
        (input: 'favicon.ico', output: 'favicon.ico', isThemePath: false),
        (input: 'static', output: '', isThemePath: false),
        (input: 'assets/static', output: '', isThemePath: true),
        (input: 'assets/media', output: 'media', isThemePath: true),
      };
      for (var item in items) {
        final inputPath = FS.join(item.isThemePath ? _themePath : state.appDir, item.input);
        final outputPath = FS.join(state.buildDir, item.output);
        if (FS.pathExistsSync(inputPath)) {
          FS.copySync(inputPath, outputPath);
        }
      }
      // CNAME
      final cnamePath = FS.join(state.buildDir, 'CNAME');
      if (state.remote.cname.isNotEmpty) {
        FS.writeStringSync(cnamePath, state.remote.cname);
      }
    } catch (e) {
      throw Mistake(message: 'copy files failed on render all: \n$e', hint: 'renderError');
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

  /// Tag to TagRender
  TagRender _tagToRender(Tag tag) {
    final link = FS.join(themeConfig.domain, themeConfig.tagPath, tag.slug, '/');
    return tag.copyWith<TagRender>({'link': link})!;
  }

  /// 筛选发布的文章并移除文章中无效的标签
  bool _filterPublishPost(Post post) {
    for (var i = post.tags.length - 1; i >= 0; i--) {
      var tag = post.tags[i];
      var value = _tagsMap[tag.slug];
      // 需要移除的标签, 确保标签都是有效的
      if (value == null) {
        post.tags.removeAt(i);
        continue;
      }
      // 设置 tag 的 count 值, 需要已发布且没有隐藏
      if (post.published && !post.hideInList) {
        value.count++;
      }
    }

    return post.published;
  }

  /// Post to PostRender
  PostRender _postToRender(Post post) {
    // 变换标签
    var currentTags = post.tags.map((t) => _tagsMap[t.slug]!.toMap());
    // TOC 目录
    var toc = '';
    // 将文章中本地图片路径，变更为线上路径
    var content = changeImageUrlToDomain(post.content);
    var html = Markdown.markdownToHtml(content, tocCallback: (data) => toc = data);
    // 渲染 MarkDown to HTML
    // 返回数据
    return post.copyWith<PostRender>({
      'tags': currentTags.toList(),
      'toc': toc,
      'content': html,
      'abstract': Markdown.markdownToHtml(changeImageUrlToDomain(post.abstract)),
      'description': _getSummaryForContent(content),
      'dateFormat': themeConfig.dateFormat.isNotEmpty ? post.date.format(pattern: themeConfig.dateFormat) : post.date,
      'feature': _getPostFeature(post.feature),
      'link': FS.join(themeConfig.domain, themeConfig.postPath, post.fileName, '/'),
      'stats': _statsCalc(content).toMap(),
    })!;
  }

  /// 将文章中本地图片路径，变更为线上路径
  String changeImageUrlToDomain(String content) {
    return content.replaceAll(featureReg, '${themeConfig.domain}/post-images/');
  }

  /// 获取 post stats 信息
  Stats _statsCalc(String str) {
    var stats = Stats();
    var cnReg = RegExp(r'[\u4E00-\u9FA5]*');
    var enReg = RegExp(
        r'[a-zA-Z0-9_\u0392-\u03c9\u0400-\u04FF]+|[\u4E00-\u9FFF\u3400-\u4dbf\uf900-\ufaff\u3040-\u309f\uac00-\ud7af\u0400-\u04FF]+|[\u00E4\u00C4\u00E5\u00C5\u00F6\u00D6]+|\w+');
    var cn = str.length - str.replaceAll(cnReg, '').length;
    var en = str.length - str.replaceAll(enReg, '').length;
    var minutes = (cn / 300 + en / 160).ceil();
    // 字数
    stats.words = cn + en;
    // 最少阅读分钟数
    stats.text = '$minutes min read';
    stats.minutes = minutes;
    // time
    stats.time = (minutes * 60).floor() * 1000;
    return stats;
  }

  /// 获取内容摘要
  String _getSummaryForContent(String content) {
    // 移除换行符, 删除 style, 移除 HTML 标签
    content = content.replaceAll(RegExp(r'(\n)|(<style(.+)?>([\s\S]*)</style>)|(<[^<>]+>)'), '');
    content = content.replaceAllMapped(RegExp(r'[!@#$%^&*()_+-=\[\]{};:"\\|,.<>/?`~\s\r\t\v\f' r"']", multiLine: true, caseSensitive: false), (str) {
      return '&#${str[0]?.codeUnits[0].toRadixString(16)};';
    });
    // 摘要
    return content.substring(0, 120) + (content.length > 120 ? '...' : '');
  }

  /// 获取封面图 URL
  String _getPostFeature(String feature) {
    // 不显示封面图
    if (!themeConfig.showFeatureImage) {
      return '';
    }
    // 默认图片
    if (feature.isEmpty) {
      return FS.join(themeConfig.domain, 'post-images/post-feature.jpg');
    }
    // 网络图
    if (feature.startsWith('http')) {
      return feature;
    }

    return FS.join(themeConfig.domain, 'post-images', feature.replaceAll(featureReg, ''));
  }
}

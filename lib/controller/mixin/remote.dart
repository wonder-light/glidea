import 'package:flutter_js/flutter_js.dart' show HandlePromises, getJavascriptRuntime;
import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/deploy.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';
import 'package:jiffy/jiffy.dart' show Jiffy;

/// 混合 - 远程
mixin RemoteSite on StateController<Application>, DataProcess, ThemeSite {
  /// 检测是否可以进行发布
  bool get checkPublish {
    final remote = state.remote;
    return switch (remote.platform) {
      DeployPlatform.github ||
      DeployPlatform.gitee ||
      DeployPlatform.coding =>
        remote.branch.isNotEmpty && remote.domain.isNotEmpty && remote.token.isNotEmpty && remote.repository.isNotEmpty,
      // TODO: Handle this case.
      DeployPlatform.sftp => throw UnimplementedError(),
      DeployPlatform.netlify => remote.netlifySiteId.isNotEmpty && remote.netlifyAccessToken.isNotEmpty,
    };
  }

  /// 匹配 feature 本地图片路径的正则
  RegExp get featureReg => RegExp(r'file.*/post-images/');

  /// 渲染 post 的数据
  List<PostRender> _postsData = [];

  /// 渲染 tag 的数据
  List<TagRender> _tagsData = [];
  Map<String, TagRender> _tagsMap = {};

  /// 菜单数据
  List<Menu> _menusData = [];

  /// 是不是首页
  bool _isHomepage = false;

  /// 当前主题路径
  String _themePath = '';

  /// 发布站点
  Future<void> publishSite() async {
    // 检测主题是否有效
    if (!selectThemeValid) {
      Get.error('noValidCurrentTheme');
      return;
    }
    // 检测是否可以发布
    if (!checkPublish) {
      Get.error('syncWarning');
      return;
    }
    try {
      // render
      await renderAll();
      var result = await Deploy.create(state).publish();
      if (result != Incident.success) {
        Get.error(result.message);
        return;
      }
      // 成功
      Get.success('syncSuccess');
    } catch (e) {
      Get.error('syncError1');
    }
  }

  /// 预览站点
  Future<void> previewSite() async {
    if (!selectThemeValid) {
      Get.error('noValidCurrentTheme');
      return;
    }
    // 设置域名
    state.themeConfig.domain = 'http://localhost:${state.previewPort}';
    await renderAll();
  }

  /// 渲染所有
  Future<void> renderAll() async {
    _themePath = FS.joinR(state.appDir, 'themes', state.themeConfig.selectTheme);
    await _clearOutputFolder();
    await _formatDataForRender();
    await _buildCss();
  }

  /// 清理输出目录
  Future<void> _clearOutputFolder() async {
    try {
      FS.deleteDirSync(state.buildDir);
      FS.createDirSync(state.buildDir);
    } catch (e) {
      Log.i('Delete file error: $e');
    }
  }

  /// 为呈现页面格式化数据
  Future<void> _formatDataForRender() async {
    // 标签
    _tagsData = state.tags.map(_tagToRender).toList();
    // 标签 slug - 对象
    _tagsMap = {
      for (var item in _tagsData) item.slug: item,
    };
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
      com = Jiffy.parse(next.date).diff(Jiffy.parse(prev.date)).toInt();
      return com;
    });
    // 菜单数据
    _menusData = state.menus.map((m) => m.copyWith<Menu>({'link': '${themeConfig.domain}${m.link}'})!).toList();
    // 渲染数据路径
    final renderDataPath = FS.joinR(state.supportDir, 'render_data.json');
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
      throw Mistake(message: 'build template’s render data failed: $e', hint: 'renderError');
    }
  }

  /// 构建 CSS
  Future<void> _buildCss() async {
    // 使用 css
    final cssFilePath = FS.joinR(_themePath, 'assets', 'styles', 'main.css');
    final cssFolderPath = FS.joinR(state.buildDir, 'styles');
    final styleOverridePath = FS.joinR(_themePath, 'style-override.js');
    // 结果
    String cssString = '';
    // 创建 styles 目录
    FS.createDirSync(cssFolderPath);
    // 获取 main.css 内容
    if (FS.fileExistsSync(cssFilePath)) {
      cssString += await FS.readString(cssFilePath);
    }
    // 设置 style override
    if (FS.fileExistsSync(styleOverridePath)) {
      // 变量
      String custom = themeCustomConfig.toJson();
      String js = 'module = {};let params = $custom;';
      // 内容
      js += await FS.readString(styleOverridePath);
      js += '''
      if (generateOverride != null) {
        generateOverride(params)
      }
      else if (module.exports instanceof Function) {
        module.exports(params)
      }
      ''';
      // 执行 js
      final javascriptRuntime = getJavascriptRuntime();
      var jsResult = await javascriptRuntime.evaluateAsync(js, sourceUrl: styleOverridePath);
      javascriptRuntime.executePendingJob();
      var asyncResult = await javascriptRuntime.handlePromise(jsResult);

      cssString += asyncResult.stringResult;
    }
    // 写入内容
    if (cssString.isNotEmpty) {
      await FS.writeString(FS.joinR(cssFolderPath, 'main.css'), cssString);
    }
  }

  /// Tag to TagRender
  TagRender _tagToRender(Tag tag) {
    final link = FS.joinR(themeConfig.domain, themeConfig.tagPath, tag.slug, '/');
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
      // 设置 tag 的 count 值
      value.count++;
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
      'dateFormat': themeConfig.dateFormat.isNotEmpty ? Jiffy.parse(post.date).format(pattern: themeConfig.dateFormat) : post.date,
      'feature': _getPostFeature(post.feature),
      'link': FS.joinR(themeConfig.domain, themeConfig.postPath, post.fileName, '/'),
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
    if (feature.isEmpty) {
      return themeConfig.showFeatureImage ? '${themeConfig.domain}/post-images/post-feature.jpg' : '';
    }
    if (feature.contains('http')) {
      return feature;
    }

    return '${themeConfig.domain}/post-images/${feature.replaceAll(featureReg, '')}';
  }
}

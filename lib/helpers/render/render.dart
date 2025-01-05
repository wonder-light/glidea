import 'dart:io' show FileMode;
import 'dart:math' show min;

import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/helpers/render/sitemap.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';
import 'package:glidea/models/theme.dart';
import 'package:jinja/jinja.dart' show Environment;
import 'package:jinja/loaders.dart';

typedef _TChangeData = TChangeCallback<TJsonMap, TJsonMap>;

/// 对选择的主题进行渲染
final class RemoteRender {
  RemoteRender({required this.site});

  /// Site App 数据
  final Application site;

  /// 主题路径
  late final String themePath = FS.join(site.appDir, 'themes', site.themeConfig.selectTheme);

  /// jinja 执行环境
  late Environment env;

  /// 匹配 feature 本地图片路径的正则
  ///
  /// 'file://.*/post-images/' => '/post-images/'
  ///
  /// (?<=匹配开头).*(?=匹配结尾)
  late final RegExp featureReg = RegExp(featurePrefix + r'.*(?=/post-images)');

  /// 渲染 post 的数据
  final List<PostRender> postsData = [];

  /// [postsData] 中未隐藏的数据
  final List<PostRender> showPosts = [];

  /// 渲染 tag 的数据
  final List<TagRender> tagsData = [];
  final Map<String, TagRender> _tagsMap = {};

  /// 菜单数据
  List<Menu> menusData = [];

  /// 站点地图
  late Sitemap sitemap;

  String get domain => site.themeConfig.domain;

  Theme get themeConfig => site.themeConfig;

  Map<String, dynamic> get customConfig => site.themeCustomConfig;

  String get cname => site.remote.cname;

  /// 清理输出目录
  Future<void> clearOutputFolder() async {
    try {
      FS.deleteDirSync(site.buildDir);
      FS.createDirSync(site.buildDir);
    } catch (e) {
      throw Mistake(message: 'clear output folder failed: \n$e', hint: 'renderError');
    }
  }

  /// 为呈现页面格式化数据
  Future<void> formatDataForRender() async {
    try {
      // 标签
      tagsData.clear();
      _tagsMap.clear();
      for (var tag in site.tags) {
        // 创建 TagRender
        final link = FS.join(domain, themeConfig.tagPath, tag.slug, '/');
        final value = tag.copyWith<TagRender>({'link': link})!;
        // 记录 TagRender
        _tagsMap[value.slug] = value;
        tagsData.add(value);
      }
      // 文章
      postsData.clear();
      for (var post in site.posts) {
        // 未发布的不要
        if (!post.published) continue;
        // 序列化后的标签
        final List<TJsonMap?> postTags = [];
        // 文章的标签
        for (var i = post.tags.length - 1; i >= 0; i--) {
          var tagSlug = post.tags[i];
          var tag = _tagsMap[tagSlug];
          // 需要移除的标签, 确保标签都是有效的
          if (tag == null) {
            post.tags.removeAt(i);
          } else {
            postTags.add(tag.toMap());
            // 未隐藏则数量加一
            if (!post.hideInList) tag.count++;
          }
        }
        // TOC 目录
        var toc = '';
        // 将文章中本地图片路径，变更为线上路径
        var content = FS.readStringSync(FS.join(site.appDir, 'posts', '${post.fileName}.md'));
        content = _changeImageUrlToDomain(content);
        var abstract = Markdown.markdownToHtml(_changeImageUrlToDomain(post.abstract));
        var html = Markdown.markdownToHtml(content, tocCallback: (data) => toc = data);
        // 渲染 MarkDown to HTML
        // 返回数据
        final postRender = post.copyWith<PostRender>({
          'tags': postTags,
          'toc': toc,
          'content': html,
          'abstract': Markdown.markdownToHtml(_changeImageUrlToDomain(post.abstract)),
          'description': abstract.isNotEmpty ? abstract : _getSummaryForContent(content),
          'dateFormat': themeConfig.dateFormat.isNotEmpty ? post.date.format(pattern: themeConfig.dateFormat) : post.date,
          'feature': _getPostFeature(post.feature),
          'link': FS.join(domain, themeConfig.postPath, post.fileName, '/'),
          'stats': _statsCalc(content).toMap(),
        })!;
        postsData.add(postRender);
      }
      // 对 post 进行排序, 置顶优先, 其次新发布的在前
      // compareFn(a, b) 返回值    排序顺序
      //  > 0	                    a 在 b 后，如 [b, a]
      //  < 0	                    a 在 b 前，如 [a, b]
      //  === 0	                  保持 a 和 b 原来的顺序
      postsData.sort((prev, next) {
        int com = (next.isTop ? 1 : 0) - (prev.isTop ? 1 : 0);
        if (com != 0) return com;
        com = next.date.compareTo(prev.date);
        return com;
      });
      // 添加未隐藏的 post
      showPosts.clear();
      showPosts.addAll(postsData.where((p) => !p.hideInList));
      // 菜单数据
      menusData = site.menus.map((m) => m.copy<Menu>()!).toList();
    } catch (e) {
      throw Mistake.add(message: 'format data failed', hint: Tran.renderError, error: e);
    }
  }

  /// 复制文件
  Future<void> copyFiles() async {
    try {
      final items = {
        (input: 'post-images', output: 'post-images', isThemePath: false),
        (input: 'images', output: 'images', isThemePath: false),
        (input: 'favicon.ico', output: 'favicon.ico', isThemePath: false),
        (input: 'static', output: '', isThemePath: false),
        (input: 'static', output: '', isThemePath: true),
        (input: 'assets/media', output: 'media', isThemePath: true),
        (input: 'assets/styles', output: 'styles', isThemePath: true),
      };
      for (var item in items) {
        final inputPath = FS.join(item.isThemePath ? themePath : site.appDir, item.input);
        final outputPath = FS.join(site.buildDir, item.output);
        if (FS.pathExistsSync(inputPath)) {
          FS.copySync(inputPath, outputPath);
        }
      }
      // CNAME
      final cnamePath = FS.join(site.buildDir, 'CNAME');
      if (cname.isNotEmpty) {
        FS.writeStringSync(cnamePath, cname);
      }
    } catch (e) {
      throw Mistake(message: 'copy files failed on render all: \n$e', hint: 'renderError');
    }
  }

  /// 构建模板
  Future<void> buildTemplate() async {
    sitemap = Sitemap();
    env = Environment(
      globals: {
        'site': {
          'posts': postsData,
          'tags': tagsData,
          'menus': menusData,
          'themeConfig': themeConfig,
          'customConfig': customConfig,
          'utils': {
            'now': DateTime.now().millisecondsSinceEpoch,
          },
          'isHomepage': false,
        },
      },
      autoReload: true,
      loader: FileSystemLoader(
        paths: ['$themePath/templates'],
        recursive: false,
        extensions: {'j2'},
      ),
      leftStripBlocks: true,
      trimBlocks: true,
    );
    await buildCss();
    await buildHome();
    await buildArchives();
    await buildTags();
    await buildPostDetail();
    await buildTagDetail();
    await buildCustomPage();
    await buildSiteMap();
  }

  /// 构建 css
  Future<void> buildCss() async {
    final cssPath = FS.join(themePath, 'style-override.j2');
    // 没有时退出
    if (!FS.fileExistsSync(cssPath)) return;
    final result = env.fromString(FS.readStringSync(cssPath)).render(customConfig);
    final outPath = FS.join(site.buildDir, 'styles', 'main.css');
    // 追加到文件末尾
    FS.writeStringSync(outPath, result, mode: FileMode.append);
  }

  /// 渲染首页页面
  Future<void> buildHome() async => await _buildPostList(urlPath: '', templatePath: homeTemplate, pageSize: defaultPostPageSize);

  /// 渲染归档页面
  Future<void> buildArchives() async {
    await _buildPostList(urlPath: themeConfig.archivePath, templatePath: archivesTemplate, pageSize: defaultArchivesPageSize);
  }

  /// 渲染标签列表页面
  Future<void> buildTags() async {
    // tags 目录
    final tagsFolder = FS.join(site.buildDir, 'tags');
    // tags 文件
    final renderPath = FS.join(tagsFolder, 'index.html');
    FS.createDirSync(tagsFolder);
    final html = env.getTemplate(tagsTemplate).render({
      'tags': tagsData,
      'menus': menusData,
      'themeConfig': themeConfig,
    });
    FS.writeStringSync(renderPath, html);
    addSiteUrl('tags', '/');
  }

  /// 呈现文章详细信息页面，包括隐藏的文章
  Future<void> buildPostDetail() async {
    void render(PostRender post) {
      // post 文件夹位置
      final renderFolderPath = FS.join(site.buildDir, themeConfig.postPath, post.fileName);
      final html = env.getTemplate(postTemplate).render({
        'menus': menusData,
        'post': post,
        'themeConfig': themeConfig,
        'commentSetting': site.comment,
      });
      FS.createDirSync(renderFolderPath);
      FS.writeStringSync(FS.join(renderFolderPath, 'index.html'), html);
      addSiteUrl(themeConfig.postPath, post.fileName, '/');
    }

    for (var i = 0, length = showPosts.length; i < length; i++) {
      final post = showPosts[i];
      post.prevPost = i <= 0 ? null : showPosts[i - 1];
      post.nextPost = i + 1 < length ? showPosts[i + 1] : null;
      render(post);
    }
    for (var post in postsData.where((p) => p.hideInList)) {
      render(post);
    }
  }

  /// 渲染标签详细页面
  Future<void> buildTagDetail() async {
    // 筛选出正在使用的标签
    final usedTags = tagsData.where((tag) => tag.used);
    // 每个标签对应的 post 列表
    final Map<String, List<PostRender>> tagMap = {};
    for (var post in showPosts) {
      for (var tag in post.tags) {
        (tagMap[tag.slug] ??= []).add(post);
      }
    }
    for (var currentTag in usedTags) {
      // 从 showPosts 中筛选出含有 currentTag.slug 的文章
      final postList = tagMap[currentTag.slug]!;
      _buildPostList(
          urlPath: FS.join(themeConfig.tagPath, currentTag.slug),
          templatePath: tagTemplate,
          pageSize: defaultPostPageSize,
          postList: postList,
          update: (data) {
            data['tag'] = currentTag;
            return data;
          });
    }
  }

  /// 渲染自定义页面
  Future<void> buildCustomPage() async {
    final customTemplates = env.listTemplates().toSet().difference({
      homeTemplate, postTemplate, archivesTemplate, tagsTemplate, tagTemplate,
      // 👇 Glidea 保护字，因为这些文件名是 Glidea 文件夹的名称
      'images.j2', 'media.j2', 'post-images.j2', 'styles.j2',
    });
    for (var template in customTemplates) {
      String renderPath;
      // 404 页面在根目录下创建
      final name = FS.basename(template);
      if (name == '404') {
        renderPath = FS.join(site.buildDir, '404.html');
      } else {
        renderPath = FS.join(site.buildDir, name, 'index.html');
      }
      final html = env.getTemplate(template).render({
        'menus': menusData,
        'themeConfig': themeConfig,
        'commentSetting': site.comment,
      });
      FS.writeStringSync(renderPath, html);
      addSiteUrl(themeConfig.postPath, name, name == '404' ? '' : '/');
    }
  }

  /// 生成站点地图
  Future<void> buildSiteMap() async {
    // robots.txt 文件
    var str = '${themeConfig.robotsText}\nSitemap: $domain/sitemap.xml';
    FS.writeStringSync(FS.join(site.buildDir, 'robots.txt'), str);
    // 创建一个站点地图
    FS.writeStringSync(FS.join(site.buildDir, 'sitemap.xml'), sitemap.generate());
    if (themeConfig.useFeed) {
      str = Feed(
        id: domain,
        title: 'Glidea',
        link: domain,
        subtitle: themeConfig.siteDescription,
        logo: FS.join(domain, 'images/avatar.png'),
        icon: FS.join(domain, 'favicon.ico'),
        rights: 'All rights reserved 2025, Glidea',
      ).generate();
      FS.writeStringSync(FS.join(site.buildDir, 'atom.xml'), str);
    }
  }

  /// 构建具有 post list 的页面
  ///
  /// [urlPath] url 地址, home => '', archive => '/archives', tag => '/tag/{tag.slug}'
  ///
  /// [templatePath] 模板路径
  ///
  /// [pageSize] 每一个页面中的 post 数量
  ///
  /// [postList] post 列表
  ///
  /// [update] 更新渲染数据的函数
  Future<void> _buildPostList({
    required String urlPath,
    required String templatePath,
    int pageSize = defaultPostPageSize,
    List<PostRender>? postList,
    _TChangeData? update,
  }) async {
    postList = [...(postList ?? showPosts)];
    // 如果时归档的话需要按时间循序排列
    if (templatePath == archivesTemplate) {
      postList.sort((a, b) => b.date.compareTo(a.date));
    }
    // 页面的域名路径
    var domain = FS.join(this.domain, urlPath);
    // 当文章列表为空时是否跳过, tag 页面需要跳过
    var skipEmpty = templatePath == 'tag.j2';
    // 条件判断函数
    bool condition(i) {
      // tag: 没有 post 时不需要需渲染
      if (skipEmpty && postList!.isEmpty) {
        return false;
      }
      // 没有 post 时也需要需渲染
      return (i - 1) * pageSize <= postList!.length;
    }

    for (var i = 1; condition(i); i++) {
      // 以 pageSize 进行分割
      final posts = postList.sublist((i - 1) * pageSize, min(i * pageSize, postList.length));
      // home 页面的 urlPath == ''
      final isHomepage = urlPath == '' && i <= 1;
      // i <= 1 => urlPath
      // i > 1 => {urlPath}/page/{i}
      final currentUrlPath = i <= 1 ? urlPath : FS.join(urlPath, 'page', '$i/');
      // i <= 1 => ''
      // i == 2 => {domain}/
      // i > 2 => {domain}/page/{i - 1}
      final prev = i <= 1
          ? ''
          : i > 2
              ? FS.join(domain, 'page', '$i/')
              : FS.join(domain, '/');
      final next = i * pageSize >= postList.length ? '' : FS.join(domain, 'page', '${i + 1}/');
      // 创建目录
      FS.createDirSync(FS.join(site.buildDir, currentUrlPath));
      // 渲染文件的路径
      final renderPath = FS.join(site.buildDir, currentUrlPath, 'index.html');
      // 渲染数据
      final renderData = {
        'posts': posts,
        'menus': menusData,
        'pagination': {'prev': prev, 'next': next},
        'themeConfig': themeConfig,
        'site': {'isHomepage': isHomepage}
      };
      // 渲染模板
      final html = env.getTemplate(templatePath).render(update == null ? renderData : update(renderData));
      // 写入文件
      FS.writeStringSync(renderPath, html);
      addSiteUrl(currentUrlPath);
    }
  }

  /// 将文章中本地图片路径，变更为线上路径
  String _changeImageUrlToDomain(String content) {
    return content.replaceAll(featureReg, domain);
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
    if (!themeConfig.showFeatureImage) return '';
    // 网络图
    if (feature.startsWith('http')) return feature;
    // 图片
    return FS.join(domain, 'post-images', feature.isNotEmpty ? feature : 'post-images/post-feature.jpg');
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

  /// 添加站点地图的 URl
  void addSiteUrl(String path1, [String? path2, String? path3]) {
    sitemap.add(SitemapEntry(location: FS.join(domain, path1, path2, path3)));
  }
}

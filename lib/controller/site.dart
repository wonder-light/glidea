import 'dart:io';

import 'package:get/get.dart' show FirstWhereOrNullExt, StateController, StatusDataExt;
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/tag.dart';
import 'package:path_provider/path_provider.dart';

/// 站点控制器
class SiteController extends StateController<Application> {
  /// 发布的网址
  String get domain => state.themeConfig.domain;

  // 标签
  List<Tag> get tags => state.tags;

  @override
  void onInit() async {
    super.onInit();
    futurize(initData);
  }

  @override
  void dispose() async {
    super.dispose();
    await saveSiteData();
  }

  /// 初始化数据
  Future<Application> initData() async {
    var site = Application();
    await checkDir(site);
    return await loadSiteData(site);
  }

  /// 检查 .glidea 文件夹是否存在，如果不存在，则将其初始化
  Future<void> checkDir(Application site) async {
    // 用户文件夹
    final home = FS.join((await getApplicationSupportDirectory()).path, '../../../../');
    // 文档
    final document = FS.join((await getApplicationDocumentsDirectory()).path);
    // 检查是否存在 .hve-notes 文件夹，如果存在，则加载它，否则使用默认配置。
    final appConfigFolderOld = FS.join(home, '.hve-notes');
    final appConfigFolder = FS.join(home, '.glidea');
    final appConfigPath = FS.join(appConfigFolder, 'config.json');

    site.baseDir = FS.normalize(Directory.current.path);
    site.appDir = FS.join(document, 'glidea');
    site.buildDir = FS.join(appConfigFolder, 'output');

    try {
      // 如果存在的话 '.hve-notes' 配置文件夹，将文件夹名称更改为 '.glidea'
      if (!FS.pathExistsSync(appConfigFolder) && FS.pathExistsSync(appConfigFolderOld)) {
        FS.renameDirSync(appConfigFolderOld, appConfigFolder);
      }
      // 创建默认目录 '.glidea'
      if (!FS.pathExistsSync(appConfigFolder)) {
        FS.createDirSync(appConfigFolder);
      }
      // 创建 config.json 文件
      if (!FS.pathExistsSync(appConfigPath)) {
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${site.appDir}"}');
      }
      // 输出目录
      if (!FS.pathExistsSync(site.buildDir)) {
        FS.createDirSync(site.buildDir);
      }
      // 获取配置
      final appConfig = FS.readStringSync(appConfigPath).deserialize<TJsonMap>()!;
      site.appDir = FS.normalize(appConfig['sourceFolder']);

      // 网站文件夹不存在
      if (!FS.pathExistsSync(site.appDir)) {
        FS.createDirSync(site.appDir);
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${site.appDir}"}');
        FS.copySync(FS.join(site.baseDir, '', 'assets/public/default-files'), site.appDir);
        return;
      }

      // 网站文件夹存在
      final items = ['images', 'config', 'post-images', 'posts', 'themes', 'static'];
      for (var folder in items) {
        final folderPath = FS.join(site.appDir, folder);
        if (!FS.pathExistsSync(folderPath)) {
          FS.copySync(FS.join(site.baseDir, '', 'assets/public/default-files', folder), folderPath);
        }
      }

      // 复制 output/favicon.ico 到 Glidea/favicon.ico
      final outputFavicon = FS.join(site.buildDir, 'favicon.ico');
      final sourceFavicon = FS.join(site.appDir, 'favicon.ico');
      if (FS.pathExistsSync(outputFavicon) && !FS.pathExistsSync(sourceFavicon)) {
        FS.copyFileSync(outputFavicon, sourceFavicon);
      }
    } catch (e) {
      Log.w(e);
    }
  }

  /// 加载配置
  Future<Application> loadSiteData(Application site) async {
    final configPath = FS.join(site.appDir, 'config');
    final configJsonPath = FS.join(configPath, 'config.json');
    TJsonMap config = {};

    // 兼容 Gridea
    if (FS.pathExistsSync(configJsonPath)) {
      // 获取配置
      config = FS.readStringSync(configJsonPath).deserialize<TJsonMap>()!;
    } else {
      final postPath = FS.join(configPath, 'posts.json');
      final remotePath = FS.join(configPath, 'setting.json');
      final themePath = FS.join(configPath, 'theme.json');
      // 获取配置
      final posts = FS.readStringSync(postPath).deserialize<TJsonMap>()!;
      final remote = FS.readStringSync(remotePath).deserialize<TJsonMap>()!;
      final theme = FS.readStringSync(themePath).deserialize<TJsonMap>()!;
      // 修改 json 中的部分名称
      if (remote.containsKey('setting')) {
        remote['remote'] = remote.remove('setting');
      }
      if (theme.containsKey('config')) {
        theme['themeConfig'] = theme.remove('config');
      }
      if (theme.containsKey('customConfig')) {
        theme['themeCustomConfig'] = theme.remove('customConfig');
      }
      // 扁平化 post 中的 data 字段
      if (posts.containsKey('post') && posts['post'] is List<TJsonMap>) {
        for (var item in posts['post'] as List<TJsonMap>) {
          if (!item.containsKey('data')) continue;
          // 扁平化
          item.addAll(item.remove('data'));
        }
      }
      // 合并数据
      config = theme.mergeMaps(posts).mergeMaps(remote);
    }

    // 将配置全部合并到 base 中
    site = site.copyWith(config)!;
    // 主题名列表
    var themeConfig = site.themeConfig;
    var themes = site.themes = FS.subDir(FS.join(site.appDir, 'themes'));
    // 设置使用的主题名
    if (!themes.contains(themeConfig.themeName)) {
      themeConfig.themeName = themes.first;
    }
    // 合并选定主题数据
    var themePath = FS.join(site.appDir, 'config', 'theme.${themeConfig.themeName}.config.json');
    if (FS.pathExistsSync(themePath)) {
      final customConfig = FS.readStringSync(themePath).deserialize<TJsonMap>()!;
      site.themeCustomConfig = site.themeCustomConfig.mergeMaps(customConfig);
    }
    // 返回数据
    return site;
  }

  /// 保存配置到文件
  Future<void> saveSiteData() async {
    final site = state;
    final configPath = FS.join(site.appDir, 'config');
    // 自定义主题配置
    if (site.themeCustomConfig.isNotEmpty) {
      final customThemePath = FS.join(configPath, 'theme.${site.themeConfig.themeName}.config.json');
      FS.writeStringSync(customThemePath, site.themeCustomConfig.toJson());
    }
    // 更新应用配置
    FS.writeStringSync(FS.join(configPath, 'config.json'), (site as ApplicationBase).toJson());
    // 更新设置
    FS.writeStringSync(site.buildDir, '{"sourceFolder": "${site.appDir}"}');
  }

  /// 更新站点的全部数据
  void updateSite(Application site) {
    TJsonMap? data = site.toMap();
    if (data == null) return;
    setSuccess(state.copyWith(data)!);
  }

  /// 获取首页左侧面板上显示的数量
  String getHomeLeftPanelNum(String name) {
    // 加载中则返回默认字符串
    if (status.isLoading) return '';
    return switch (name) {
      'article' => '${state.posts.length}',
      'menu' => '${state.menus.length}',
      'tag' => '${state.tags.length}',
      _ => '',
    };
  }

  /// 创建标签, 需要保证 slug 唯一
  Tag createTag() {
    return Tag()..slug = Uid.shortId;
  }

  /// 添加新标签
  void updateTag({required Tag newTag, Tag? oldTag}) {
    oldTag = state.tags.firstWhereOrNull((t) => t == oldTag);
    if (oldTag == null) {
      // 添加标签
      state.tags.add(newTag);
    } else {
      // 更新
      oldTag.name = newTag.name;
      oldTag.slug = newTag.slug;
    }
    refresh();
  }

  /// 删除新标签
  void removeTag(Tag tag) {
    if (tag.used) return;
    if (state.tags.remove(tag)) {
      refresh();
    }
  }
}

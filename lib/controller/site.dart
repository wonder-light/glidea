import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart' show JsonMapper;
import 'package:get/get.dart' show GetxController, StateMixin, StatusDataExt;
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/application.dart';
import 'package:path_provider/path_provider.dart';

/// 站点控制器
class SiteController extends GetxController with StateMixin<Application> {
  /// 发布的网址
  String get domain => state.db.themeConfig.domain;

  @override
  void onInit() async {
    super.onInit();
    setLoading();
    await initData();
  }

  @override
  void dispose() async {
    super.dispose();
    await this.saveSiteData();
  }

  /// 初始化数据
  Future<void> initData() async {
    var data = Application();
    await checkDir(data);
    data = await loadSiteData(data);
    setSuccess(data);
  }

  /// 检查 .glidea 文件夹是否存在，如果不存在，则将其初始化
  Future<void> checkDir(Application data) async {
    // 用户文件夹
    final home = FS.join((await getApplicationSupportDirectory()).path, '../../../../');
    // 文档
    final document = FS.join((await getApplicationDocumentsDirectory()).path);
    // 检查是否存在 .hve-notes 文件夹，如果存在，则加载它，否则使用默认配置。
    final appConfigFolderOld = FS.join(home, '.hve-notes');
    final appConfigFolder = FS.join(home, '.glidea');
    final appConfigPath = FS.join(appConfigFolder, 'config.json');

    data.baseDir = FS.normalize(Directory.current.path);
    data.appDir = FS.join(document, 'glidea');
    data.buildDir = FS.join(appConfigFolder, 'output');

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
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${data.appDir}"}');
      }
      // 输出目录
      if (!FS.pathExistsSync(data.buildDir)) {
        FS.createDirSync(data.buildDir);
      }
      // 获取配置
      final appConfig = FS.readStringSync(appConfigPath).deserialize<Map<String, dynamic>>()!;
      data.appDir = FS.normalize(appConfig['sourceFolder']);

      // 网站文件夹不存在
      if (!FS.pathExistsSync(data.appDir)) {
        FS.createDirSync(data.appDir);
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${data.appDir}"}');
        FS.copySync(FS.join(data.baseDir, '', 'assets/public/default-files'), data.appDir);
        return;
      }

      // 网站文件夹存在
      final items = ['images', 'config', 'post-images', 'posts', 'themes', 'static'];
      for (var folder in items) {
        final folderPath = FS.join(data.appDir, folder);
        if (!FS.pathExistsSync(folderPath)) {
          FS.copySync(FS.join(data.baseDir, '', 'assets/public/default-files', folder), folderPath);
        }
      }

      // 复制 output/favicon.ico 到 Glidea/favicon.ico
      final outputFavicon = FS.join(data.buildDir, 'favicon.ico');
      final sourceFavicon = FS.join(data.appDir, 'favicon.ico');
      if (FS.pathExistsSync(outputFavicon) && !FS.pathExistsSync(sourceFavicon)) {
        FS.copyFileSync(outputFavicon, sourceFavicon);
      }
    } catch (e) {
      Log.w(e);
    }
  }

  /// 加载配置
  Future<Application> loadSiteData(Application data) async {
    final configPath = FS.join(data.appDir, 'config/config.json');
    Map<String, dynamic> config = {};

    // 兼容 Gridea
    if (FS.pathExistsSync(configPath)) {
      // 获取配置
      config = FS.readStringSync(configPath).deserialize<Map<String, dynamic>>()!;
    } else {
      final postPath = FS.join(data.appDir, 'config/posts.json');
      final remotePath = FS.join(data.appDir, 'config/setting.json');
      final themePath = FS.join(data.appDir, 'config/theme.json');
      // 获取配置
      final posts = FS.readStringSync(postPath).deserialize<Map<String, dynamic>>()!;
      final remote = FS.readStringSync(remotePath).deserialize<Map<String, dynamic>>()!;
      final theme = FS.readStringSync(themePath).deserialize<Map<String, dynamic>>()!;
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
      // 合并数据
      config = theme.mergeMaps(posts).mergeMaps(remote);
    }

    // 将配置全部合并到 base 中
    data.db = data.db.copyWithObj(config.fromMap<ApplicationDb>()!)!;
    // 主题名列表
    var themeConfig = data.db.themeConfig;
    var themes = data.db.themes = FS.subDir(FS.join(data.appDir, 'themes'));
    // 设置使用的主题名
    if (!themes.contains(themeConfig.themeName)) {
      themeConfig.themeName = themes.first;
    }
    // 合并选定主题数据
    var themePath = FS.join(data.appDir, 'config', 'theme.${themeConfig.themeName}.config.json');
    if (FS.pathExistsSync(themePath)) {
      final customConfig = FS.readStringSync(themePath).deserialize<Map<String, dynamic>>()!;
      data.db.themeCustomConfig = data.db.themeCustomConfig.mergeMaps(customConfig);
    }
    // 返回数据
    return data;
  }

  /// 保存配置到文件
  Future<void> saveSiteData() async {
    final site = state;
    final data = site.db;
    final configPath = FS.join(site.appDir, 'config');
    // 自定义主题配置
    if (data.themeCustomConfig.isNotEmpty) {
      final customThemePath = FS.join(configPath, 'theme.${data.themeConfig.themeName}.config.json');
      FS.writeStringSync(customThemePath, data.themeCustomConfig.toJson());
    }
    // 更新应用配置
    FS.writeStringSync(FS.join(configPath, 'config.json'), (data as ApplicationBase).toJson());
    // 更新设置
    FS.writeStringSync(site.buildDir, '{"sourceFolder": "${site.appDir}"}');
  }

  /// 更新站点的全部数据
  void updateSite(Application siteData) {
    Map<String, dynamic>? data = JsonMapper.toMap(siteData);
    if (data == null) return;
    setSuccess(JsonMapper.copyWith(state, data)!);
  }

  /// 获取首页左侧面板上显示的数量
  String getHomeLeftPanelNum(String name) {
    // 加载中则返回默认字符串
    if (status.isLoading) return '';
    return switch (name) {
      'article' => '${state.db.posts.length}',
      'menu' => '${state.db.menus.length}',
      'tag' => '${state.db.tags.length}',
      _ => '',
    };
  }
}

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
    final defaultAppDir = FS.join(document, 'glidea');

    data.baseDir = FS.normalize(Directory.current.path);
    data.appDir = defaultAppDir;
    data.buildDir = FS.join(appConfigFolder, 'output');

    try {
      // 如果存在的话 '.hve-notes' 配置文件夹，将文件夹名称更改为 '.glidea'
      if (!FS.pathExistsSync(appConfigFolder) && FS.pathExistsSync(appConfigFolderOld)) {
        FS.renameDirSync(appConfigFolderOld, appConfigFolder);
      }
      // 创建默认目录 '.glidea'
      if (!FS.pathExistsSync(appConfigFolder)) {
        FS.createDirSync(appConfigFolder);
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${data.appDir}"}');
      }
      // 输出目录
      if (!FS.pathExistsSync(data.buildDir)) {
        FS.createDirSync(data.buildDir);
      }
      // 获取配置
      final appConfig = FS.readStringSync(appConfigPath).deserialize<Map<String, dynamic>>()!;
      data.appDir = FS.normalize(appConfig['sourceFolder']);

      // 网站文件夹已存在
      if (FS.pathExistsSync(data.appDir)) {
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

        return;
      }

      // 网站文件夹不存在
      data.appDir = defaultAppDir;
      final jsonString = '{"sourceFolder": "${data.appDir}"}';
      FS.writeStringSync(appConfigPath, jsonString);
      FS.createDirSync(data.appDir);

      FS.copySync(FS.join(data.baseDir, '', 'assets/public/default-files'), data.appDir);
    } catch (e) {
      Log.w(e);
    }
  }

  /// 加载配置
  Future<Application> loadSiteData(Application data) async {
    final postPath = FS.join(data.appDir, 'config/posts.json');
    final remotePath = FS.join(data.appDir, 'config/setting.json');
    final themePath = FS.join(data.appDir, 'config/theme.json');
    // 获取配置
    final posts = FS.readStringSync(postPath).deserialize<Map<String, dynamic>>()!;
    final remote = FS.readStringSync(remotePath).deserialize<Map<String, dynamic>>()!;
    final theme = FS.readStringSync(themePath).deserialize<Map<String, dynamic>>()!;
    // 将配置全部合并到 data 中
    final config = JsonMapper.mergeMaps(theme, JsonMapper.mergeMaps(posts, remote));
    return data.copyWith<Application>(config)!;
  }

  /// 保存配置到文件
  Future<void> saveSiteData() async {
    // TODO: 保存配置
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

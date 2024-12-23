import 'dart:io' show Directory;
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show AsyncCallback;
import 'package:get/get.dart' show Get, GetNavigationExt, GetStringUtils, StateController;
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/translations.dart';
import 'package:glidea/models/application.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory, getApplicationSupportDirectory;

/// 混合 - 数据处理
mixin DataProcess on StateController<Application> {
  // 创建开始
  bool _isCreate = true;

  /// 语言代码
  Map<String, String> get languages => TranslationsService.languages;

  /// 初始化数据
  Future<Application> initData() async {
    var site = Application();
    try {
      // 检查目录
      await checkDir(site);
      // 加载数据
      site = await loadSiteData(site);
    } catch (e) {
      Log.e(e);
    }
    return site;
  }

  /// 控制器状态设置为 success 后调佣
  void initState() async {
    // 设置语言
    setLanguage(state.language);
  }

  /// 释放状态
  Future<void> disposeState() async {
    await saveSiteData();
  }

  /// 检查 .glidea 文件夹是否存在，如果不存在，则将其初始化
  ///
  /// throw [Mistake] exception
  Future<void> checkDir(Application site) async {
    // 创建开始
    final isCreate = _isCreate;
    _isCreate = false;
    // 应用程序支持目录, 即配置所在的目录
    final appConfigFolder = FS.normalize((await getApplicationSupportDirectory()).path);
    // 应用程序文档目录
    final document = FS.normalize((await getApplicationDocumentsDirectory()).path);
    // 检查是否存在 .hve-notes 文件夹，如果存在，则加载它，否则使用默认配置。
    final appConfigFolderOld1 = FS.join(appConfigFolder, '.hve-notes');
    final appConfigFolderOld2 = FS.join(appConfigFolder, '.glidea');
    final appConfigPath = FS.join(appConfigFolder, 'config.json');
    var defaultSiteDir = FS.join(document, 'glidea');

    // 如果已经设置了目录则不必重新设置目录
    site.appDir = site.appDir.isEmpty ? defaultSiteDir : site.appDir;
    site.baseDir = FS.normalize(Directory.current.path);
    site.buildDir = FS.join(appConfigFolder, 'output');
    site.supportDir = appConfigFolder;

    try {
      // 如果存在的话 '.gridea' 配置文件夹，则将其移动到 appConfigFolder 目录下
      if (FS.pathExistsSync(appConfigFolderOld2)) {
        FS.moveSubFile(appConfigFolderOld2, appConfigFolder);
      }
      // 如果存在的话 '.hve-notes' 配置文件夹，则将其移动到 appConfigFolder 目录下
      if (FS.pathExistsSync(appConfigFolderOld1)) {
        FS.moveSubFile(appConfigFolderOld1, appConfigFolder);
      }
    } catch (e) {
      throw Mistake(message: 'move old config folder failed: \n$e');
    }
    try {
      // 创建 config.json 文件
      if (!FS.pathExistsSync(appConfigPath)) {
        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${site.appDir}"}');
      } else {
        final appConfig = FS.readStringSync(appConfigPath).deserialize<TJsonMap>()!;
        defaultSiteDir = FS.normalize(appConfig['sourceFolder']);
        // 如果时默认目录则进行覆盖
        if (isCreate) {
          site.appDir = defaultSiteDir;
        }
      }
      // 输出目录
      if (!FS.pathExistsSync(site.buildDir)) {
        FS.createDirSync(site.buildDir);
      }
    } catch (e) {
      throw Mistake(message: 'create or read config.json file failed: \n$e');
    }
    // 当保存的目录修改后将旧目录移动到新目录
    if (site.appDir != defaultSiteDir) {
      try {
        if (!FS.dirExistsSync(site.appDir)) {
          // 目录不存在时才可以重命名
          FS.renameDirSync(defaultSiteDir, site.appDir);
        } else {
          FS.copySync(defaultSiteDir, site.appDir);
          FS.deleteDirSync(defaultSiteDir);
        }

        FS.writeStringSync(appConfigPath, '{"sourceFolder": "${site.appDir}"}');
        return;
      } catch (e) {
        throw Mistake(message: 'move appDir failed: \n$e');
      }
    }
    if (isCreate) {
      try {
        // 将不存在的文件解压到指定路径
        FS.unzip('assets/public/default-files.zip', site.appDir, isAsset: true, cover: false);
      } catch (e) {
        throw Mistake(message: 'copy default files to appDir failed: \n$e');
      }
    }
  }

  /// 加载配置
  ///
  /// throw [Mistake] exception
  Future<Application> loadSiteData(Application site) async {
    final configPath = FS.join(site.appDir, 'config');
    final configJsonPath = FS.join(configPath, 'config.json');

    if (FS.fileExistsSync(configJsonPath)) {
      try {
        // 获取配置
        TJsonMap config = FS.readStringSync(configJsonPath).deserialize<TJsonMap>()!;
        // 将配置全部合并到 base 中
        site = site.copyWith<Application>(config)!;
      } catch (e) {
        throw Mistake(message: 'read and merge site data failed: \n$e');
      }
    } else {
      // 兼容 Gridea, 获取数据
      site = _transformDataForPath(site);
    }

    try {
      // 主题名列表
      var themeConfig = site.themeConfig;
      var themes = site.themes = FS.subDir(FS.join(site.appDir, 'themes'));
      // 设置使用的主题名
      if (themes.isNotEmpty && !themes.contains(themeConfig.selectTheme)) {
        themeConfig.selectTheme = themes.first;
      }
      // 使用选定主题数据
      var themePath = FS.join(site.appDir, 'config', 'theme.${themeConfig.selectTheme}.config.json');
      if (FS.fileExistsSync(themePath)) {
        site.themeCustomConfig = FS.readStringSync(themePath).deserialize<TJsonMap>()!;
      }
    } catch (e) {
      throw Mistake(message: 'set theme data failed: \n$e');
    }
    // APP 信息
    var packageInfo = await PackageInfo.fromPlatform();
    site.appName = packageInfo.appName;
    site.packageName = packageInfo.packageName;
    site.version = packageInfo.version;
    site.buildNumber = packageInfo.buildNumber;
    // 返回数据
    return site;
  }

  /// 保存配置到文件, 保存后进行 [refresh]
  ///
  /// throw [Mistake] exception
  Future<void> saveSiteData({AsyncCallback? callback}) async {
    // 设置状态
    setLoading();
    try {
      // 先执行回调
      await callback?.call();
    } catch (e) {
      setSuccess(state);
      rethrow;
    }
    final site = state;
    // 检查目录
    await checkDir(site);
    final configPath = FS.join(site.appDir, 'config');
    try {
      // 自定义主题配置
      if (site.themeCustomConfig.isNotEmpty) {
        final customThemePath = FS.join(configPath, 'theme.${site.themeConfig.selectTheme}.config.json');
        FS.writeStringSync(customThemePath, site.themeCustomConfig.toJson());
      }
      // 更新应用配置
      FS.writeStringSync(FS.join(configPath, 'config.json'), site.copy<ApplicationDb>()!.toJson());
    } catch (e) {
      throw Mistake(message: 'write application config failed: \n$e');
    }
    // 设置状态
    setSuccess(state);
    // 保存后刷新数据
    refresh();
  }

  /// 更新站点的全部数据
  ///
  /// throw [Mistake] exception
  void updateSite(Application site) {
    saveSiteData(callback: () async {
      await Future.delayed(const Duration(milliseconds: 10));
    });
  }

  /// 设置语言代码
  void setLanguage(String code) {
    if (languages[code] == null) {
      code = languages.keys.first;
    }
    // 刚开始加载数据时 [state] 为 null
    state.language = code;
    var [lang, country] = code.split('_');
    Get.updateLocale(Locale(lang, country));
  }

  // 从路径中获取 Gridea 的数据
  Application _transformDataForPath(Application site) {
    // 数据
    TJsonMap data = {};
    // config 路径
    final configPath = FS.join(site.appDir, 'config');
    // 配置路径
    final paths = {
      // post 数据
      FS.join(configPath, 'posts.json'),
      // remote 数据
      FS.join(configPath, 'setting.json'),
      // theme 数据
      FS.join(configPath, 'theme.json'),
    };
    for (var path in paths) {
      // 判断是否存在
      if (FS.fileExistsSync(path)) {
        try {
          final config = FS.readStringSync(path).deserialize<TJsonMap>()!;
          // 更改 setting.json 中 config 的名称
          if (path.contains('setting.json')) {
            config['setting'] = config['config'];
          }
          // 合并配置
          data = data.mergeMaps(config);
        } catch (e) {
          Log.w('read gridea data failed: $e');
        }
      }
    }
    if (data.isNotEmpty) {
      try {
        // 将配置全部合并到 base 中
        site = site.copyWith<Application>(_transformData(data))!;
      } catch (e) {
        Log.w('merge gridea data failed: $e');
      }
    }
    return site;
  }

  /// 将 Gridea 的数据处理为适合该应用的数据
  TJsonMap _transformData(TJsonMap data) {
    // 修改 json 中的部分名称
    if (data.containsKey('setting')) {
      data['remote'] = data.remove('setting');
    }
    if (data.containsKey('config')) {
      final config = data.remove('config');
      config['tagUrlFormat'] = (config['tagUrlFormat'] as String).camelCase;
      config['postUrlFormat'] = (config['postUrlFormat'] as String).camelCase;
      // 将字符串格式化
      data['themeConfig'] = config;
    }
    if (data.containsKey('customConfig')) {
      data['themeCustomConfig'] = data.remove('customConfig');
    }
    // 扁平化 post 中的 data 字段
    if (data['posts'] case List<Map> posts when posts.isNotEmpty) {
      // 最外层的标签源数据 tag.name - tag
      TJsonMap tagsMap = {};
      // 记录标签
      if (data['tags'] case List<Map> tags when tags.isNotEmpty) {
        for (var tag in tags) {
          tagsMap[tag['name']] = tag;
        }
      }
      // 对每个 post 进行处理
      for (var post in posts) {
        // 扁平化 data
        if (post['data'] is Map) {
          post.addAll(post.remove('data'));
        }
        // 更改 tags 的内容
        if (post['tags'] case List<String> tags when tags.isNotEmpty) {
          post['tags'] = tags.map((tagName) => tagsMap[tagName]).toList();
        }
      }
    }
    // 将字符串格式化
    if (data['menus'] case List<Map> menus when menus.isNotEmpty) {
      for (var menu in menus) {
        menu['openType'] = (menu['openType'] as String).camelCase;
      }
    }
    // 将配置全部合并到 base 中
    return data;
  }
}

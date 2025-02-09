﻿part of 'site.dart';

/// 混合 - 数据处理
mixin DataProcess on StateController<Application> {
  // 创建开始
  bool _isCreate = true;

  /// 语言代码
  Map<String, String> get languages => TranslationsService.languages;

  /// 在控制价初始化时进行数据的的初始化
  @protected
  Future<Application> loadSiteData() async {
    var site = Application();
    try {
      // 检查目录
      await _checkDir(site);
      // 加载数据
      site = await _loadSiteData(site);
    } catch (e, s) {
      Log.e('load site data failed', error: e, stackTrace: s);
    }
    return site;
  }

  /// 控制器状态设置为 success 后调佣
  void initState() {
    // 设置语言
    setLanguage(state.language);
  }

  /// 释放状态
  Future<void> disposeState() async {
    try {
      await saveSiteData();
    } catch (e, s) {
      Log.e('dispose site controller state failed', error: e, stackTrace: s);
    }
  }

  /// 在站点目录下创建文件和目录, 或者将不存在的文件或目录补全
  ///
  /// 创建或更新输出目录或配置
  ///
  /// 站点目录结构如下:
  /// ```
  /// config.json ------------- 配置文件夹
  /// │   ├── config.json ----- 配置文件
  /// │   └── ...... ---------- 其它文件
  /// images ------------------ 图片文件夹
  /// │   ├── avatar.png ------ 头像
  /// │   └── ...... ---------- 其它图片
  /// post-images ------------- 文章的图片文件夹
  /// │   ├── post-feature.jpg - 默认封面
  /// │   └── ...... ----------- 其它封面
  /// posts -------------------- 文章文件夹
  /// │   ├── about.md --------- Markdown 文章
  /// │   └── ...... ----------- 其它文章
  /// static ------------------- 静态文件夹
  /// │   └── 404.html --------- 404 页面
  /// themes ------------------- 主题文件夹
  /// │   ├── simple ----------- simple 主题文件夹
  /// │   └── ...... ----------- 其它主题文件夹
  /// favicon.ico -------------- 图标
  /// ```
  ///
  /// 出错时掏出 [Exception] 异常
  Future<void> _checkDir(Application site) async {
    // 创建开始, 只使用一次
    final isCreate = _isCreate;
    const dirField = 'appDir';
    _isCreate = false;
    // 应用程序支持目录, 即配置所在的目录
    final appConfigFolder = FS.normalize((await getApplicationSupportDirectory()).path);
    // 应用程序文档目录
    final document = FS.normalize((await getApplicationDocumentsDirectory()).path);
    final appConfigPath = FS.join(appConfigFolder, 'config.json');
    var defaultSiteDir = FS.join(document, 'glidea');

    // 如果已经设置了目录则不必重新设置目录
    site.appDir = site.appDir.isEmpty ? defaultSiteDir : site.appDir;
    site.baseDir = FS.normalize(Directory.current.path);
    site.buildDir = FS.join(appConfigFolder, 'output');
    site.supportDir = appConfigFolder;

    // 创建 config.json 文件
    if (!FS.fileExistsSync(appConfigPath)) {
      FS.writeStringSync(appConfigPath, '{"$dirField": "${site.appDir}"}');
    } else {
      final appConfig = FS.readStringSync(appConfigPath).deserialize<TJsonMap>()!;
      defaultSiteDir = FS.normalize(appConfig[dirField] ?? site.appDir);
    }
    // 在刚打开应用时应该直接进行覆盖, 而不用进行其它操作
    if (isCreate) {
      site.appDir = defaultSiteDir;
      // 将不存在的文件解压到指定路径
      await FS.unzip(src: 'assets/public/default-files.zip', target: site.appDir, cover: false);
    }
    // 输出目录
    if (!FS.dirExistsSync(site.buildDir)) {
      FS.createDirSync(site.buildDir);
    }

    // 当保存的目录修改后将旧目录移动到新目录
    if (site.appDir != defaultSiteDir) {
      if (!FS.dirExistsSync(site.appDir)) {
        // 目录不存在时才可以重命名
        FS.renameDirSync(defaultSiteDir, site.appDir);
      } else {
        FS.copySync(defaultSiteDir, site.appDir);
        FS.deleteDirSync(defaultSiteDir);
      }

      FS.writeStringSync(appConfigPath, '{"$dirField": "${site.appDir}"}');
    }
  }

  /// 从 config/config.json 中加载配置
  ///
  /// 出错时掏出 [Exception] 异常
  Future<Application> _loadSiteData(Application site) async {
    final postsPath = FS.join(site.appDir, 'posts');
    final configPath = FS.join(site.appDir, 'config');
    final configJsonPath = FS.join(configPath, 'config.json');

    // 获取配置
    TJsonMap config = FS.readStringSync(configJsonPath).deserialize<TJsonMap>()!;
    // 将配置全部合并到 base 中
    site = site.copyWith<Application>(config)!;
    // 移除文件不存在的 post
    site.posts.removeWhere((post) => !FS.fileExistsSync(FS.join(postsPath, '${post.fileName}.md')));
    // 主题名列表
    var themeConfig = site.themeConfig;
    var themes = site.themes = FS.subDir(FS.join(site.appDir, 'themes'));
    // 设置使用的主题名
    if (themes.isNotEmpty && !themes.contains(themeConfig.selectTheme)) {
      themeConfig.selectTheme = themes.first;
    }
    // 使用选定主题数据
    var themePath = FS.join(configPath, 'theme.${themeConfig.selectTheme}.config.json');
    if (FS.fileExistsSync(themePath)) {
      site.themeCustomConfig = FS.readStringSync(themePath).deserialize<TJsonMap>()!;
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

  /// 将配置保存到 config/config.json 文件, 保存后进行 [refresh]
  ///
  /// 出错时掏出 [Exception] 异常
  Future<void> saveSiteData({AsyncCallback? callback}) async {
    try {
      // 设置状态
      setLoading();
      // 先执行回调
      await callback?.call();
      await Background.instance.saveSiteData(state);
    } finally {
      // 设置状态
      setSuccess(state);
      // 保存后刷新数据
      refresh();
    }
  }

  /// 更新站点的全部数据
  ///
  /// 出错时掏出 [Exception] 异常
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
}

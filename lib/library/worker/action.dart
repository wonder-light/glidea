part of 'worker.dart';

/// 后台操作
base mixin BackgroundAction on BackgroundWorker {
  static const Symbol _publishSite = Symbol('publishSite');
  static const Symbol _previewSite = Symbol('previewSite');
  static const Symbol _remoteDetect = Symbol('remoteDetect');
  static const Symbol _loadSiteData = Symbol('loadSiteData');
  static const Symbol _saveSiteData = Symbol('saveSiteData');
  static const Symbol _loadAsset = Symbol('loadAsset');
  static const Symbol _log = Symbol('log');
  static const Symbol _loadThemeCustomConfig = Symbol('loadThemeCustomConfig');
  static const Symbol _saveThemeImage = Symbol('saveThemeImage');
  static const Symbol _saveThemeConfig = Symbol('saveThemeConfig');
  static const Symbol _exportZipFile = Symbol('exportZipFile');

  @override
  Future<void> onInit() async {
    await super.onInit();
    _invokes.addAll({
      _loadAsset: _loadAssetBundle,
      _log: _printLog,
    });
  }

  /// 发布站点
  Future<void> publishSite(Application site) async {
    await call<void>(_publishSite, [site]);
  }

  /// 预览站点
  Future<void> previewSite(Application site) async {
    await call<void>(_previewSite, [site]);
  }

  /// 预览站点
  Future<void> remoteDetect(RemoteSetting remote, String appDir, String buildDir) async {
    await call<void>(_remoteDetect, [remote, appDir, buildDir]);
  }

  /// 从 config/config.json 中加载配置
  ///
  /// 出错时掏出 [Exception] 异常
  Future<Application> loadSiteData() async {
    return await call<Application>(_loadSiteData);
  }

  /// 将配置保存到 config/config.json 文件, 保存后进行 [refresh]
  ///
  /// 出错时掏出 [Exception] 异常
  Future<void> saveSiteData(Application site) async {
    return await call(_saveSiteData, [site]);
  }

  /// 获取自定义主题的控件配置
  ///
  /// [values] 是自定义主题配置
  ///
  /// [configPath] 自定义主题的配置文件路径
  Future<List<ConfigBase>> loadThemeCustomConfig(TJsonMap values, String configPath) async {
    return await call<List<ConfigBase>>(_loadThemeCustomConfig, [values, configPath]);
  }

  /// 保存主题的配置
  Future<ThemeCall> saveThemeConfig(Application site, List<ConfigBase> themes, List<ConfigBase> customs) async {
    return await call<ThemeCall>(_saveThemeConfig, [site, themes, customs]);
  }

  /// 保存主题配置中的图片
  Future<void> saveThemeImage(PictureConfig picture) async {
    return await call<void>(_saveThemeImage, [picture]);
  }

  /// 加载资源
  Future<Uint8List> _loadAssetBundle(String key) async {
    return (await rootBundle.load(key)).buffer.asUint8List();
  }

  // 打印日志
  Future<void> _printLog(Level level, dynamic message) async {
    Log.log(level, message);
  }

  /// 导出渲染完成的的 zip 文件到指定文件夹
  Future<bool> exportZipFile(String path, Application site) async {
    return await call<bool>(_exportZipFile, [path, site]);
  }
}

/// 用于调用前台的操作
base mixin ActionBack on WorkerProcess {
  /// 加载资源猫
  Future<Uint8List> loadAssets(String path) async {
    return await call<Uint8List>(BackgroundAction._loadAsset, [path]);
  }

  /// 打印消息
  Future<void> log(dynamic message, {Level level = Level.info}) async {
    await call(BackgroundAction._log, [level, message]);
  }
}

/// 加载本地数据
base mixin DataBack on ActionBack {
  // 创建开始
  bool _isCreate = true;

  @override
  Future<void> onInit() async {
    await super.onInit();
    _invokes.addAll({
      BackgroundAction._loadSiteData: loadSiteData,
      BackgroundAction._saveSiteData: saveSiteData,
      BackgroundAction._saveThemeImage: saveThemeImage,
    });
  }

  /// 从 config/config.json 中加载配置
  ///
  /// 出错时掏出 [Exception] 异常
  Future<Application> loadSiteData() async {
    var site = Application();
    // 检查目录
    await _checkDir(site);
    // 加载数据
    site = await _loadSiteData(site);
    return site;
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
      defaultSiteDir = FS.normalize(appConfig[dirField]);
    }
    // 在刚打开应用时应该直接进行覆盖, 而不用进行其它操作
    if (isCreate) {
      site.appDir = defaultSiteDir;
      // 在 Isolate 中无法使用 rootBundle.load
      final bytes = await loadAssets('assets/public/default-files.zip');
      // 将不存在的文件解压到指定路径
      FS.unzip(bytes: bytes, target: site.appDir, cover: false);
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
      // 写入配置
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
    if (!themes.contains(themeConfig.selectTheme)) {
      themeConfig.selectTheme = themes.firstOrNull ?? themeConfig.selectTheme;
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
  Future<void> saveSiteData(Application site) async {
    _isCreate = false;
    // 将 post 的 content 设为 ''
    for (var post in site.posts) {
      post.content = '';
    }
    // 检查目录
    await _checkDir(site);
    final configPath = FS.join(site.appDir, 'config');
    // 自定义主题配置
    final customThemePath = FS.join(configPath, 'theme.${site.themeConfig.selectTheme}.config.json');
    FS.writeStringSync(customThemePath, site.themeCustomConfig.toJson());
    // 更新应用配置
    FS.writeStringSync(FS.join(configPath, 'config.json'), site.copy<ApplicationDb>()!.toJson());
  }

  /// 保存主题配置中的图片
  Future<void> saveThemeImage(PictureConfig picture) async {
    // 路径
    final path = FS.join(picture.folder, picture.value);
    if (picture.filePath.isEmpty || picture.filePath == path) return;
    // 保存并压缩
    await ImageExt.compress(picture.filePath, path);
    picture.filePath = path;
  }
}

/// 远程操作
base mixin RemoteBack on DataBack {
  /// 今天文件服务
  HttpServer? fileServer;

  @override
  Future<void> onInit() async {
    await super.onInit();
    _invokes.addAll({
      BackgroundAction._publishSite: publishSite,
      BackgroundAction._previewSite: previewSite,
      BackgroundAction._remoteDetect: remoteDetect,
      BackgroundAction._exportZipFile: exportZipFile,
    });
  }

  /// 发布站点
  Future<void> publishSite(Application site) async {
    // 设置域名
    site.themeConfig.domain = site.remote.domain;
    // render
    await _renderAll(site);
    await Deploy.create(site.remote, site.appDir, site.buildDir).publish();
  }

  /// 预览站点
  Future<void> previewSite(Application site) async {
    // 设置域名
    site.themeConfig.domain = 'http://localhost:${site.previewPort}';
    // render
    await _renderAll(site);
    // 启动静态文件服务
    await _enableStaticServer(site);
  }

  /// 远程检测
  Future<void> remoteDetect(RemoteSetting remote, String appDir, String buildDir) async {
    await Deploy.create(remote, appDir, buildDir).remoteDetect();
  }

  /// 启动静态文件服务器
  ///
  /// 出错时抛出 [Exception] 异常
  Future<void> _enableStaticServer(Application site) async {
    if (fileServer == null) {
      // 启动服务
      var handler = createStaticHandler(site.buildDir, defaultDocument: 'index.html');
      fileServer = await shelf_io.serve(handler, 'localhost', site.previewPort, shared: true);
    }
    // 打开网址
    await launchUrlString(site.themeConfig.domain);
  }

  /// 渲染所有
  ///
  /// 当构建失败时抛出 [Exception] 错误
  Future<void> _renderAll(Application site) async {
    final render = RemoteRender(site: site);
    await render.clearOutputFolder();
    await render.formatDataForRender();
    await render.copyFiles();
    await render.buildTemplate();
  }

  /// 导出渲染完成的的 zip 文件到指定文件夹
  Future<bool> exportZipFile(String path, Application site) async {
    // 设置域名
    site.themeConfig.domain = site.remote.domain;
    await _renderAll(site);
    await FS.zipDir(src: site.buildDir, target: path);
    return true;
  }
}

/// 加载主题数据
base mixin ThemeBack on DataBack {
  @override
  Future<void> onInit() async {
    await super.onInit();
    _invokes.addAll({
      BackgroundAction._loadThemeCustomConfig: loadThemeCustomConfig,
      BackgroundAction._saveThemeConfig: saveThemeConfig,
    });
  }

  /// 获取自定义主题的控件配置
  ///
  /// [values] 是自定义主题配置
  ///
  /// [configPath] 自定义主题的配置文件路径
  List<ConfigBase> loadThemeCustomConfig(TJsonMap values, String configPath) {
    // 判断对象是否是空值
    bool isNotValid(dynamic value) {
      return switch (value) {
        null => true,
        String str => str.isEmpty,
        Iterable list => list.isEmpty,
        _ => false,
      };
    }

    // 基础配置列表
    List<ConfigBase> lists = [];
    if (!FS.fileExistsSync(configPath)) return [];
    // 配置数据
    final configs = FS.readStringSync(configPath).deserialize<TJsonMap>()!;
    // 自定义配置中的 customConfig 字段
    var customConfig = configs['customConfig'] as List<dynamic>;
    if (customConfig.isEmpty) return [];
    // 实例化字段
    for (var item in customConfig) {
      // 转换为字段配置实例
      var base = (item as Object).deserialize<ConfigBase>()!;

      // 设置值
      var itemValue = values[base.name];
      var value = isNotValid(itemValue) ? base.value : itemValue;
      // 当 value 为 list 需要 cast value 的类型为 List<Map>
      if (value is List) {
        base.value = List.of((value).cast<TJsonMap>());
      } else {
        base.value = value;
      }

      lists.add(base);
    }
    return lists;
  }

  /// 保存主题的配置
  Future<ThemeCall> saveThemeConfig(Application site, List<ConfigBase> themes, List<ConfigBase> customs) async {
    // 更新主题数据
    TJsonMap items = {};
    for (var config in themes) {
      if (config is PictureConfig) {
        await saveThemeImage(config);
      }
      items[config.name] = config.value;
    }
    site.themeConfig = site.themeConfig.copyWith<Theme>(items)!;
    // 更新自定义主题数据
    items = {};
    for (var config in customs) {
      if (config is PictureConfig) {
        await saveThemeImage(config);
      }
      items[config.name] = config.value;
    }
    // Map 在合并后需要使用新的 Map 对象, 旧的 Map 对象在序列化时会报错
    site.themeCustomConfig = site.themeCustomConfig.mergeMaps(items);
    // 保存数据
    await saveSiteData(site);
    return (theme: site.themeConfig, themeCustom: site.themeCustomConfig);
  }
}

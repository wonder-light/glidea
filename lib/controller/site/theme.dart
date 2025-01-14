part of 'site.dart';

/// 混合 - 主题
mixin ThemeSite on DataProcess {
  /// 拥有的主题名列表
  List<String> get themes => state.themes;

  /// 主题配置
  Theme get themeConfig => state.themeConfig;

  /// 自定义主题配置
  TJsonMap get themeCustomConfig => state.themeCustomConfig;

  /// 当前选择的主题有效
  bool get selectThemeValid {
    var selectTheme = state.themeConfig.selectTheme;
    if (selectTheme.isEmpty) return false;
    // 查看是否有路径
    var path = FS.join(state.appDir, 'themes', selectTheme);
    if (!FS.dirExistsSync(path)) return false;
    return true;
  }

  /// 主题配置中变量名称与字段类型的映射
  final Map<String, FieldType> _fieldNames = {
    'selectTheme': FieldType.select,
    'faviconSetting': FieldType.picture,
    'avatarSetting': FieldType.picture,
    'siteName': FieldType.input,
    'siteAuthor': FieldType.input,
    'siteDescription': FieldType.textarea,
    'footerInfo': FieldType.textarea,
    'showFeatureImage': FieldType.toggle,
    'postPageSize': FieldType.slider,
    'archivesPageSize': FieldType.slider,
    // TODO: 设置 post 和 tag 的 URL 格式, slug => hello-word, shortId => 3ji39
    //'postUrlFormat': FieldType.radio,
    //'tagUrlFormat': FieldType.radio,
    'postPath': FieldType.input,
    'tagPath': FieldType.input,
    'archivePath': FieldType.input,
    'dateFormat': FieldType.input,
    'useFeed': FieldType.toggle,
    'feedCount': FieldType.slider,
    'generateSiteMap': FieldType.toggle,
    'robotsText': FieldType.textarea,
  };

  /// 主题下拉列表中的选项
  List<SelectOption>? _themeOptions;

  @override
  void initState() {
    super.initState();
    // 主题列表
    _themeOptions ??= state.themes.map((t) => SelectOption().setValues(label: t, value: t)).toList();
  }

  /// 获取主题的控件配置
  ///
  /// 都需要 [ArrayConfig] 时, throw [Exception] exception
  List<ConfigBase> getThemeWidgetConfig() {
    return createRenderConfig(
      fields: _fieldNames,
      fieldValues: state.themeConfig.toMap()!,
      options: {
        'selectTheme': _themeOptions!,
      },
      fieldNotes: {
        'siteDescription': 'htmlSupport',
        'footerInfo': 'htmlSupport',
        'dateFormat': 'yyyy-MM-dd HH:mm:ss',
        'robotsText': 'htmlSupport',
      },
      sliderMax: {
        'postPageSize': 50,
      },
    ).values.toList();
  }

  /// 获取自定义主题的控件配置
  List<ConfigBase> getThemeCustomWidgetConfig() {
    try {
      List<ConfigBase> lists = [];
      // 自定义配置 - 字段的值
      var values = state.themeCustomConfig;
      // 自定义主题的配置文件路径
      final configPath = FS.join(state.appDir, 'themes', state.themeConfig.selectTheme, 'config.json');
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
        var value = values[base.name] ?? base.value;
        // 当 value 为 list 需要 cast value 的类型为 List<Map>
        if (value is List) {
          base.value = (value).cast<TJsonMap>();
        } else {
          base.value = value;
        }

        lists.add(base);
      }

      return lists;
    } catch (e, s) {
      Log.e('get custom theme render config failed', error: e, stackTrace: s);
      return [];
    }
  }

  /// 创建渲染配置
  ///
  /// [fields] 渲染配置需要的字段:  [字段名] - [渲染类型]
  ///
  /// [fieldValues] 字段对应的值:  [字段名] - [字段值]
  Map<String, ConfigBase> createRenderConfig({
    required Map<String, FieldType> fields,
    Map<String, dynamic>? fieldValues,
    Map<String, String>? fieldLabels,
    Map<String, String>? fieldNotes,
    Map<String, String>? fieldHints,
    Map<String, int>? sliderMax,
    Map<String, List<SelectOption>>? options,
    Map<String, List<ConfigBase>>? arrayItems,
  }) {
    final Map<String, ConfigBase> children = {};
    for (var field in fields.entries) {
      final key = field.key;
      // 创建配置
      final ConfigBase config = switch (field.value) {
        FieldType.input => InputConfig()..hint = fieldHints?[key]?.tr ?? '',
        FieldType.textarea => TextareaConfig()..hint = fieldHints?[key]?.tr ?? '',
        FieldType.select => SelectConfig()..options = options?[key] ?? [],
        FieldType.radio => RadioConfig()..options = options?[key] ?? [],
        FieldType.toggle => ToggleConfig(),
        FieldType.slider => SliderConfig()..max = sliderMax?[key] ?? 100,
        FieldType.picture => PictureConfig(),
        FieldType.array => ArrayConfig()..arrayItems = arrayItems?[key] ?? [],
      };
      config
        ..value = fieldValues?[key] ?? config.value
        ..name = key
        ..label = fieldLabels?[key]?.tr ?? key.tr
        ..note = fieldNotes?[key]?.tr ?? '';
      children[key] = config;
    }
    return children;
  }

  /// 更新主题的配置
  ///
  /// throw [Exception] exception
  Future<bool> updateThemeConfig({List<ConfigBase> themes = const [], List<ConfigBase> customs = const []}) async {
    try {
      // 保存数据
      await saveSiteData(callback: () async {
        // 更新主题数据
        TJsonMap items = {};
        for (var config in themes) {
          if (config is PictureConfig) {
            await saveThemeImage(config);
          }
          items[config.name] = config.value;
        }
        state.themeConfig = state.themeConfig.copyWith<Theme>(items)!;
        // 更新自定义主题数据
        items = {};
        for (var config in customs) {
          if (config is PictureConfig) {
            await saveThemeImage(config);
          }
          items[config.name] = config.value;
        }
        // Map 在合并后需要使用新的 Map 对象, 旧的 Map 对象在序列化时会报错
        state.themeCustomConfig = state.themeCustomConfig.mergeMaps(items);
      });
      return true;
    } catch (e, s) {
      Log.e('update or add theme config failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 保存主题配置中的图片
  Future<void> saveThemeImage(PictureConfig picture) async {
    final path = FS.join(picture.folder, picture.value);
    if (picture.filePath == path) return;
    // 保存并压缩
    await ImageExt.compress(picture.filePath, path);
    picture.filePath = path;
  }
}

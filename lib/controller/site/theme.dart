﻿part of 'site.dart';

/// 混合 - 主题
mixin ThemeSite on DataProcess {
  /// 主题配置
  final themeWidgetConfig = <ConfigBase>[];

  /// 自定义主题配置
  final themeCustomWidgetConfig = <ConfigBase>[];

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
    themeWidgetConfig.addAll(getThemeWidgetConfig());
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
  Future<List<ConfigBase>> loadThemeCustomConfig() async {
    try {
      // 自定义主题的配置文件路径
      final configPath = FS.join(state.appDir, 'themes', state.themeConfig.selectTheme, 'config.json');
      return await Background.instance.loadThemeCustomConfig(state.themeCustomConfig, configPath);
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
    required TMap<FieldType> fields,
    TMap<dynamic>? fieldValues,
    TMap<String>? fieldLabels,
    TMap<String>? fieldNotes,
    TMap<String>? fieldHints,
    TMap<int>? sliderMax,
    TMapLists<SelectOption>? options,
    TMapLists<ConfigBase>? arrayItems,
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

  /// 保存并更新主题的配置
  ///
  /// throw [Exception] exception
  Future<bool> saveThemeConfig({List<ConfigBase> themes = const [], List<ConfigBase> customs = const []}) async {
    try {
      final value = await Background.instance.saveThemeConfig(state, themes, customs);
      state.themeConfig = value.theme;
      state.themeCustomConfig = value.themeCustom;
      return true;
    } catch (e, s) {
      Log.e('update or add theme config failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 保存主题配置中的图片
  Future<void> saveThemeImage(PictureConfig picture) async {
    await Background.instance.saveThemeImage(picture);
  }
}

﻿import 'package:get/get.dart' show Get, StateController, Trans;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/theme.dart';

import 'data.dart';

/// 混合 - 主题
mixin ThemeSite on StateController<Application>, DataProcess {
  /// 拥有的主题名列表
  List<String> get themes => state.themes;

  /// 当前是主题的自定义页面
  bool? isThemeCustomPage;

  /// 当前主题的资源目录
  ///
  /// themePage:
  ///
  ///     appDir,
  ///
  /// themeCustomPage:
  ///
  ///     appDir + selectTheme + assets,
  String get currentThemeAssetsPath => switch (isThemeCustomPage) {
        true => FS.join(state.appDir, 'themes', state.themeConfig.selectTheme, 'assets'),
        _ => state.appDir,
      };

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
    'siteDescription': FieldType.textarea,
    'footerInfo': FieldType.textarea,
    'showFeatureImage': FieldType.toggle,
    'postPageSize': FieldType.slider,
    'archivesPageSize': FieldType.slider,
    'postUrlFormat': FieldType.radio,
    'tagUrlFormat': FieldType.radio,
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

  /// URL 的格式选项
  List<SelectOption>? _urlFormatOptions;

  /// 获取主题的控件配置
  ///
  /// 都需要 [ArrayConfig] 时, throw [Mistake] exception
  List<ConfigBase> getThemeWidgetConfig() {
    // 主题列表
    _themeOptions ??= state.themes.map((t) => SelectOption().setValues(label: t, value: t)).toList();
    // URL 默认格式
    _urlFormatOptions ??= [
      SelectOption().setValues(label: 'Slug'.tr, value: UrlFormats.slug.name),
      SelectOption().setValues(label: 'Short ID'.tr, value: UrlFormats.shortId.name),
    ];
    return createRenderConfig(
      fields: _fieldNames,
      fieldValues: state.themeConfig.toMap()!,
      options: {
        'selectTheme': _themeOptions!,
        'postUrlFormat': _urlFormatOptions!,
        'tagUrlFormat': _urlFormatOptions!,
      },
      fieldNotes: {
        'siteDescription': 'htmlSupport',
        'footerInfo': 'htmlSupport',
        'robotsText': 'htmlSupport',
      },
      sliderMax: {
        'postPageSize': 50,
      },
    ).values.toList();
  }

  /// 获取自定义主题的控件配置
  List<ConfigBase> getThemeCustomWidgetConfig() {
    List<ConfigBase> lists = [];
    // 自定义配置 - 字段的值
    var values = state.themeCustomConfig;
    try {
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
    } catch (e) {
      Log.w('get custom theme render config failed: \n$e');
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
        ..label = fieldLabels?[key] ?? key.tr
        ..note = fieldNotes?[key]?.tr ?? '';
      children[key] = config;
    }
    return children;
  }

  /// 更新主题的配置
  ///
  /// throw [Mistake] exception
  void updateThemeConfig({List<ConfigBase> themes = const [], List<ConfigBase> customs = const []}) async {
    // 保存数据
    await saveSiteData(callback: () async {
      try {
        // 更新主题数据
        TJsonMap items = {for (var config in themes) config.name: config.value};
        state.themeConfig = state.themeConfig.copyWith<Theme>(items)!;
        // 更新自定义主题数据
        items = {for (var config in customs) config.name: config.value};
        // Map 在合并后需要使用新的 Map 对象, 旧的 Map 对象在序列化时会报错
        state.themeCustomConfig = state.themeCustomConfig.mergeMaps(items);
      } catch (e) {
        throw Mistake(message: 'update theme config and custom theme config failed: \n$e');
      }
    });
    // 通知
    Get.success(Tran.themeConfigSaved);
  }
}

﻿import 'package:get/get.dart' show Get, StateController, Trans;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/theme.dart';

import 'data.dart';

/// 混合 - 主题
mixin ThemeSite on StateController<Application>, DataProcess {
  /// 拥有的主题名列表
  List<String> get themes => state.themes;

  /// 主题配置
  Theme get themeConfig => state.themeConfig;

  /// 自定义主题配置
  TJsonMap get themeCustomConfig => state.themeCustomConfig;

  /// 主题配置中变量名称与字段类型的映射
  final Map<String, FieldType> fieldMaps = {
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

  /// 获取主题的控件配置
  List<ConfigBase> getThemeWidget() {
    // 主题列表
    var themes = state.themes
        .map((t) => SelectOption()
          ..label = t
          ..value = t)
        .toList();
    // URL 默认格式
    var formats = [
      SelectOption()
        ..label = 'Slug'.tr
        ..value = UrlFormats.slug.name,
      SelectOption()
        ..label = 'Short ID'.tr
        ..value = UrlFormats.shortId.name,
    ];
    // 控件列表
    List<ConfigBase> lists = [];
    // 主题配置 {变量名: 变量值} 的映射
    TJsonMap values = state.themeConfig.toMap()!;
    // 循环添加控件
    for (var item in fieldMaps.entries) {
      // 变量名
      var name = item.key;
      // 变量值
      var value = values[name];
      // 字段控件
      ConfigBase config = switch (item.value) {
        FieldType.input => InputConfig(),
        FieldType.select => SelectConfig()..options = themes,
        FieldType.textarea => TextareaConfig()..note = 'htmlSupport'.tr,
        FieldType.radio => RadioConfig()..options = formats,
        FieldType.toggle => ToggleConfig(),
        FieldType.slider => SliderConfig()..max = name == 'postPageSize' ? 50 : 100,
        FieldType.picture => PictureConfig(),
        FieldType.array => throw UnimplementedError(),
      };

      config
        ..name = name
        ..label = name.tr
        ..value = value;

      lists.add(config);
    }

    return lists;
  }

  /// 更新主题的配置
  void updateThemeConfig({List<ConfigBase> themes = const [], List<ConfigBase> customs = const []}) async {
    setLoading();
    // 更新主题数据
    TJsonMap items = {};
    for (var config in themes) {
      items[config.name] = config.value;
    }
    state.themeConfig = state.themeConfig.copyWith<Theme>(items)!;
    // 更新自定义主题数据
    items = {};
    for (var config in customs) {
      items[config.name] = config.value;
    }
    // 保存数据
    await saveSiteData();
    // 刷新
    setSuccess(state);
    refresh();
    // 通知
    Get.success('themeConfigSaved'.tr);
  }

  /// 获取自定义主题的控件配置
  List<ConfigBase> getThemeCustomWidget() {
    List<ConfigBase> lists = [];
    // 自定义配置 - 字段的值
    var values = state.themeCustomConfig;
    try {
      // 自定义主题的配置文件路径
      final configPath = FS.joinR(state.appDir, 'themes', state.themeConfig.selectTheme, 'config.json');
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
        // 当 value 为 list 需要 cast value 的类型
        if (value is List) {
          base.value = (value).cast<TJsonMap>();
        } else {
          base.value = value;
        }
        ;
        lists.add(base);
      }

      return lists;
    } catch (e) {
      return [];
    }
  }
}

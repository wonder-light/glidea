import 'package:get/get.dart' show StateController, Trans;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/theme.dart';

/// 混合 - 主题
mixin ThemeSite on StateController<Application> {
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
  List<ConfigBase> getThemeWidgetConfig() {
    // 主题列表
    var themes = state.themes.map((t) => SelectOption.all(t)).toList();
    // URL 默认格式
    var formats = [
      SelectOption(label: 'Slug'.tr, value: UrlFormats.slug.name),
      SelectOption(label: 'Short ID'.tr, value: UrlFormats.shortId.name),
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
        FieldType.input => InputConfig(name: name, label: name.tr, value: value),
        FieldType.select => SelectConfig(name: name, label: name.tr, value: value, options: themes),
        FieldType.textarea => TextareaConfig(name: name, label: name.tr, value: value, note: 'htmlSupport'.tr),
        FieldType.radio => RadioConfig(name: name, label: name.tr, value: value, options: formats),
        FieldType.toggle => ToggleConfig(name: name, label: name.tr, value: value),
        FieldType.slider => SliderConfig(name: name, label: name.tr, value: value, max: name == 'postPageSize' ? 50 : 100),
        FieldType.picture => PictureConfig(name: name, label: name.tr, value: value),
        FieldType.array => throw UnimplementedError(),
      };

      lists.add(config);
    }

    return lists;
  }

  /// 更新主题的配置
  void updateThemeConfig(List<ConfigBase> configs) {
    TJsonMap items = {};
    for (var config in configs) {
      items[config.name] = config.value;
    }
    state.themeConfig = state.themeConfig.copyWith<Theme>(items)!;
    refresh();
  }
}

import 'package:get/get.dart' show FirstWhereOrNullExt, GetStringUtils, StateController;
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/theme.dart';

/// 混合 - 主题
mixin ThemeSite on StateController<Application> {
  // 主题配置
  Theme get themeConfig => state.themeConfig;
  // 自定义主题配置
  TJsonMap get themeCustomConfig => state.themeCustomConfig;
}

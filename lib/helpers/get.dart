import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionSnackbar, Get, GetInterface, GetNavigationExt, Trans;
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints, ResponsiveBreakpointsData;

extension GetExt on GetInterface {
  /// 关于当前屏幕的响应性数据
  ResponsiveBreakpointsData get breakpoints => ResponsiveBreakpoints.of(Get.context!);

  /// 判断是否是桌面端
  bool get isDesktop => breakpoints.isDesktop;

  /// 判断是否是移动端
  bool get isMobile => breakpoints.isMobile;

  /// 成功信息
  void success(String message) {
    _snackbar(message);
  }

  /// 错误信息
  void error(String message) {
    var colorScheme = Get.theme.colorScheme;
    _snackbar(
      message,
      iconColor: colorScheme.error,
      icon: PhosphorIconsRegular.xCircle,
      backgroundColor: colorScheme.onError,
    );
  }

  /// 提示
  void _snackbar(String message, {Color? backgroundColor, IconData? icon, Color? iconColor, Color? boxShadowColor}) {
    var colorScheme = Get.theme.colorScheme;
    Get.snackbar(
      'success'.tr,
      message.tr,
      maxWidth: 240,
      borderRadius: 10,
      backgroundColor: backgroundColor ?? colorScheme.onPrimary,
      titleText: Container(),
      icon: Icon(
        icon ?? PhosphorIconsRegular.check,
        color: iconColor ?? colorScheme.primary,
      ),
      boxShadows: [
        BoxShadow(
          color: boxShadowColor ?? colorScheme.outlineVariant,
          offset: const Offset(-4, 4),
          blurRadius: 25,
        ),
      ],
    );
  }
}

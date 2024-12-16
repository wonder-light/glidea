﻿import 'package:elegant_notification/elegant_notification.dart' show ElegantNotification;
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetInterface, GetNavigationExt, Rx, Trans;
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/enum/enums.dart';
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints, ResponsiveBreakpointsData;

/// 扩展
class RxObject<T> extends Rx<T> {
  RxObject(super.initial);

  @override
  void update(T Function(T val) fn) {
    var newValue = fn(value);
    var useUpdate = newValue == value;
    value = newValue;
    if (useUpdate) {
      // subject.add(value);
      refresh();
    }
  }
}

///  obs 方法
extension RxObjectT<T extends Object> on T {
  /// Returns a `Rx` instance with [this] `T` as initial value.
  RxObject<T> get obs => RxObject<T>(this);
}

extension GetExt on GetInterface {
  /// 关于当前屏幕的响应性数据
  ResponsiveBreakpointsData get breakpoints => ResponsiveBreakpoints.of(Get.context!);

  /// 判断是否是桌面端
  bool get isDesktop => breakpoints.isDesktop;

  /// 判断是否是移动端
  bool get isMobile => breakpoints.isMobile;

  /// 成功信息
  void success(String message) {
    _snackbar(
      message: message,
      icon: Icons.check_circle,
      iconColor: NotificationType.success.color,
    );
  }

  /// 错误信息
  void error(String message) {
    _snackbar(
      message: message,
      icon: Icons.close,
      iconColor: theme.colorScheme.error,
    );
  }

  /// 提示
  void _snackbar({
    required String message,
    double? width = 240,
    double? height = 60,
    String? title,
    IconData? icon,
    Color? iconColor,
  }) {
    ElegantNotification(
      width: width,
      height: height,
      icon: Icon(icon, color: iconColor),
      iconSize: 18,
      progressIndicatorColor: iconColor ?? theme.colorScheme.primary,
      isDismissable: false,
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 400),
      background: theme.scaffoldBackgroundColor,
      progressIndicatorBackground: theme.scaffoldBackgroundColor,
      title: title == null ? null : Text(title.tr),
      description: Text(message.tr),
      shadow: BoxShadow(
        color: theme.colorScheme.outlineVariant,
        offset: const Offset(-4, 4),
        blurRadius: 25,
      ),
    ).show(context!);
  }

  /// 在页面上创建抽屉
  ///
  /// [opacity] - 背景透明度
  ///
  /// [opacityColor] - 背景颜色
  ///
  /// [controller] - [DraController] 抽屉控制器, 用于关闭抽屉
  ///
  /// [shape] - 抽屉的形状
  ///
  /// [direction] - 抽屉出现的方向
  ///
  /// [duration] - 动画的持续时间
  ///
  /// [blur] - 背景应用模糊效果
  ///
  /// [elevation] - 放置该材料相对于其父材料的 z 坐标
  ///
  /// [stepWidth] - 如果非空，则强制子元素的宽度为该值的倍数。如果为 null 或 0.0，子元素的宽度将与其最大固有宽度相同。该值不能为负值。
  ///
  /// [stepHeight] - 如果非空，则强制子元素的宽度为该值的倍数。只在移动端生效。
  ///
  /// [width] - 宽度, 默认为 403
  ///
  /// [onClose] 关闭时的回调函数
  void showDrawer({
    required WidgetBuilder builder,
    double opacity = 0.5,
    Color? opacityColor,
    DraController? controller,
    ShapeBorder? shape,
    DrawerDirection direction = DrawerDirection.rightToLeft,
    DrawerDirection mobileDirection = DrawerDirection.center,
    Duration duration = const Duration(milliseconds: 300),
    bool blur = true,
    double elevation = 40,
    double? stepWidth = 60,
    double? stepHeight,
    double? width = 304,
    VoidCallback? onClose,
  }) {
    // 使用 [PopupRoute] 不会遮挡住下来选项中的选项弹出框
    Get.generalDialog(
      barrierColor: Colors.transparent,
      transitionDuration: duration,
      transitionBuilder: (ctx, animation, secondaryAnimation, child) => child,
      pageBuilder: (BuildContext ctx, Animation<double> animation, Animation<double> secondaryAnimation) {
        return DrawerWidget(
          controller: controller ?? DraController(),
          builder: builder,
          animation: animation,
          opacity: opacity,
          opacityColor: opacityColor,
          blur: blur,
          direction: direction,
          mobileDirection: mobileDirection,
          stepWidth: stepWidth,
          stepHeight: stepHeight,
          width: width,
          shape: shape,
          onClose: onClose,
        );
      },
    );
  }
}

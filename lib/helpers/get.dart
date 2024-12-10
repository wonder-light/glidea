import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, ExtensionSnackbar, Get, GetInterface, GetNavigationExt, Rx, Trans;
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/enum/enums.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
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
  ///
  /// TODO: 需要解决多次触发时延迟出现的问题
  void _snackbar(String message, {Color? backgroundColor, IconData? icon, Color? iconColor, Color? boxShadowColor}) {
    var colorScheme = Get.theme.colorScheme;
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.snackbar(
      'success'.tr,
      message.tr,
      maxWidth: 240,
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
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
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetInterface, GetNavigationExt;
import 'package:responsive_framework/responsive_framework.dart';

/// 这个类用于关闭抽屉
class DraController extends ValueNotifier<bool> {
  /// 任意抽屉控制器构造函数
  DraController() : super(true);

  /// 关上抽屉
  void close() {
    value = false;
    notifyListeners();
  }
}

extension DrawerExt on GetInterface {
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
  /// [align] - 抽屉对齐的方向
  ///
  /// [duration] - 动画的持续时间
  ///
  /// [blur] - 背景应用模糊效果
  ///
  /// [decoration] - 抽屉的装饰器, 控制阴影等
  ///
  /// [stepWidth] - 如果非空，则强制子元素的宽度为该值的倍数。如果为 null 或 0.0，子元素的宽度将与其最大固有宽度相同。该值不能为负值。
  ///
  /// [stepHeight] - 如果非空，则强制子元素的宽度为该值的倍数。只在移动端生效。
  void showDrawer({
    required WidgetBuilder builder,
    double opacity = 0.5,
    Color? opacityColor,
    DraController? controller,
    ShapeBorder? shape,
    Alignment? align,
    Duration duration = const Duration(milliseconds: 400),
    bool blur = true,
    Decoration? decoration,
    double? stepWidth = 60,
    double? stepHeight,
  }) {
    // 获取断点数据
    final breakpoints = ResponsiveBreakpoints.of(Get.context!);
    // 设置 stepHeight
    stepHeight = breakpoints.isDesktop ? null : (stepHeight ?? 60);
    // 设置 align
    align ??= breakpoints.isDesktop ? Alignment.centerRight : Alignment.center;
    // 背景颜色
    opacityColor ??= theme.colorScheme.outlineVariant;
    // 形状
    shape ??= const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.zero),
    );
    // 盒子的装饰器
    decoration ??= BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.outline.withOpacity(0.5),
          offset: const Offset(-10, 10),
          blurRadius: 45,
          spreadRadius: 0,
        ),
      ],
    );
    // 叠层
    final navigatorState = Navigator.of(Get.overlayContext!, rootNavigator: false);
    final overlayState = navigatorState.overlay!;
    // 控制器
    final internalController = controller ?? DraController();
    // 动画控制器
    final animationController = AnimationController(
      vsync: overlayState,
      duration: duration,
    );

    // 设置叠层实体
    final overlayEntry = OverlayEntry(builder: (context) {
      // 背景板
      Widget backboard = Opacity(
        opacity: opacity,
        child: Container(color: opacityColor),
      );

      // 模糊效果
      if (blur) {
        backboard = ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: backboard,
          ),
        );
      }

      // 背景
      backboard = FadeTransition(
        opacity: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        child: GestureDetector(
          child: backboard,
          onTap: () {
            internalController.close();
          },
        ),
      );

      // 创建抽屉内容
      Widget drawer = Align(
        alignment: align!,
        child: IntrinsicWidth(
          stepWidth: stepWidth,
          stepHeight: stepHeight,
          child: Drawer(
            shape: shape,
            child: builder(context),
          ),
        ),
      );

      // 创建抽屉动画
      if (align.x == 0 && align.y == 0) {
        drawer = FadeTransition(
          opacity: CurvedAnimation(
            parent: animationController,
            curve: Curves.easeInOut,
          ),
          child: drawer,
        );
      } else {
        drawer = SlideTransition(
          position: Tween<Offset>(
            begin: Offset(align.x, align.y),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeInOut,
            ),
          ),
          child: drawer,
        );
      }

      // 执行动画
      animationController.forward();

      // 返回堆栈
      return Stack(
        children: [
          backboard,
          drawer,
        ],
      );
    });

    // 插入
    overlayState.insert(overlayEntry);

    // 监听变化
    void listener() {
      if (internalController.value) return;
      if (animationController.isAnimating) return;
      animationController.reverse().whenCompleteOrCancel(() {
        // 关闭叠层实体
        overlayEntry
          ..remove()
          ..dispose();
        // 移除监听函数
        internalController.removeListener(listener);
      });
    }

    // 添加监听函数
    internalController.addListener(listener);
  }
}

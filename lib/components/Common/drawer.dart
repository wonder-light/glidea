import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;
import 'package:glidea/enum/enums.dart';

/// 这个类用于关闭抽屉
class DraController extends ValueNotifier<bool> {
  /// 任意抽屉控制器构造函数
  DraController() : super(true);

  VoidCallback? _onClose;

  /// 关上抽屉
  void close() {
    value = false;
    notifyListeners();
    _onClose?.call();
    Get.closeAllDialogs();
  }
}

/// 抽屉控件
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required this.builder,
    required this.animation,
    this.opacity = 0.5,
    this.opacityColor,
    this.elevation = 40,
    this.blur = true,
    this.controller,
    this.direction = DrawerDirection.rightToLeft,
    this.mobileDirection = DrawerDirection.center,
    this.stepWidth = 60,
    this.stepHeight,
    this.width = 304,
    this.height,
    this.shape,
    this.onClose,
  });

  /// 比较透明度
  final double opacity;

  /// 比较颜色
  final Color? opacityColor;

  /// 启用背景模糊
  final bool blur;

  /// 启用背景模糊
  final double elevation;

  /// 抽屉出现的方向
  final DrawerDirection direction;

  /// 移动端抽屉出现的方向
  final DrawerDirection mobileDirection;

  /// 如果非空，则强制子元素的宽度为该值的倍数。如果为 null 或 0.0，子元素的宽度将与其最大固有宽度相同。该值不能为负值
  final double? stepWidth;

  /// 如果非空，则强制子元素的宽度为该值的倍数。只在移动端生效
  final double? stepHeight;

  /// 抽屉宽度, 默认为 403
  final double? width;

  /// 抽屉宽度, 默认为 null
  final double? height;

  /// 抽屉宽度, 默认为 403
  final ShapeBorder? shape;

  /// 构建子控件
  final WidgetBuilder builder;

  /// 动画
  final Animation<double> animation;

  /// 控制器
  final DraController? controller;

  /// 关闭时的回调函数
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    // 控制器
    final DraController internalController = controller ?? DraController();
    internalController._onClose = onClose;
    // 背景板
    final bgColor = opacityColor ?? ColorScheme.of(context).outlineVariant;
    Widget backboard = Container(color: bgColor.withAlpha((opacity * 255).round()));
    // 模糊效果
    if (blur) {
      // sigmaX 与 sigmaY 过大会导致背景产生扰动
      backboard = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: backboard,
      );
    }
    // 背景
    backboard = FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
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
    Widget drawer = Drawer(
      width: width,
      shape: shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: builder(context),
    );
    // 高度
    if (height != null) {
      drawer = SizedBox(height: height, child: drawer);
    }
    // 对齐等等
    drawer = Align(
      alignment: direction.toAlign,
      child: Material(
        elevation: elevation,
        child: IntrinsicWidth(
          stepWidth: stepWidth,
          stepHeight: stepHeight,
          child: drawer,
        ),
      ),
    );
    // 判断是否要在移动端淡入
    if (direction.isFade) {
      drawer = FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: drawer,
      );
    } else {
      drawer = SlideTransition(
        position: Tween<Offset>(
          begin: direction.value,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        ),
        child: drawer,
      );
    }
    // 返回堆栈
    return Stack(
      children: [
        backboard,
        drawer,
      ],
    );
  }
}

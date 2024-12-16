import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetSnackBar, GetSnackBarState, SnackPosition;

class SnackBarWidget extends GetSnackBar {
  const SnackBarWidget({
    super.key,
    super.title,
    super.message,
    super.titleText,
    super.messageText,
    super.icon,
    super.shouldIconPulse,
    super.maxWidth,
    super.margin,
    super.padding,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
    super.backgroundColor,
    super.leftBarIndicatorColor,
    super.boxShadows,
    super.backgroundGradient,
    super.mainButton,
    super.onTap,
    super.onHover,
    super.duration,
    super.isDismissible,
    super.dismissDirection,
    super.showProgressIndicator,
    super.progressIndicatorController,
    super.progressIndicatorBackgroundColor,
    super.progressIndicatorValueColor,
    super.snackPosition = SnackPosition.top,
    super.snackStyle,
    super.forwardAnimationCurve,
    super.reverseAnimationCurve,
    super.animationDuration,
    super.barBlur,
    super.overlayBlur,
    super.overlayColor,
    super.userInputForm,
    super.snackbarStatus,
    super.hitTestBehavior,
    this.disableSelfAlignment = true,
  });

  /// 禁用对齐小部件，此修改确保当小吃店出现时，它根据其高度覆盖整个屏幕
  ///
  /// 使该部分中的小部件无法访问。将disableSelfAlignment设置为true将禁用自对齐，允许在小吃店可见时访问背景小部件
  final bool disableSelfAlignment;

  @override
  State createState() => SnackBarWidgetState();
}

class SnackBarWidgetState extends GetSnackBarState {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '<SnackBar Hero tag>',
      transitionOnUserGestures: true,
      child: ClipRect(
        clipBehavior: Clip. hardEdge,
        child: Dismissible(
          key: const Key('dismissible'),
          direction: DismissDirection. vertical,
          resizeDuration: null,
          behavior: HitTestBehavior.translucent,
          child: super.build(context),
        ),
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetInterface, GetNavigationExt;
import 'package:get/get_navigation/src/router_report.dart' show RouterReportManager;
import 'package:glidea/enum/enums.dart';
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints;

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

/// [Get] 的扩展
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
    DrawerDirection? direction,
    Duration duration = const Duration(milliseconds: 300),
    bool blur = true,
    double elevation = 40,
    double? stepWidth = 60,
    double? stepHeight,
    double? width = 304,
    BuildContext? context,
  }) {
    // 获取断点数据
    final breakpoints = ResponsiveBreakpoints.of(Get.context!);
    // 设置 stepHeight
    stepHeight = breakpoints.isDesktop ? null : (stepHeight ?? 60);
    // 设置 direction
    direction ??= breakpoints.isDesktop ? DrawerDirection.rightToLeft : DrawerDirection.center;
    // 背景颜色
    opacityColor ??= theme.colorScheme.outlineVariant;
    // 形状
    shape ??= const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.zero),
    );
    // 叠层
    final navigatorState = Navigator.of(context ?? Get.overlayContext!, rootNavigator: true);
    // 控制器
    final internalController = controller ?? DraController();
    // 动画控制器
    final animationController = AnimationController(
      vsync: navigatorState,
      duration: duration,
    );
    // 使用 [PopupRoute] 不会遮挡住下来选项中的选项弹出框
    navigatorState.push(GetDrawerRoute(
      builder: (BuildContext ctx) {
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
          alignment: direction!.toAlign,
          child: Material(
            elevation: 40,
            child: IntrinsicWidth(
              stepWidth: stepWidth,
              stepHeight: stepHeight,
              child: Drawer(
                width: width,
                shape: shape,
                child: builder(ctx),
              ),
            ),
          ),
        );

        if (direction.isFade) {
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
              begin: direction.value,
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
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) => child,
    ));
    // 监听变化
    void listener() {
      if (internalController.value) return;
      if (animationController.isAnimating) return;
      animationController.reverse().whenCompleteOrCancel(() {
        // 关闭叠层实体
        navigatorState.pop();
        // 移除监听函数
        internalController.removeListener(listener);
      });
    }
    // 添加监听函数
    internalController.addListener(listener);
  }
}

/// 抽屉的 Popup 路由
class GetDrawerRoute<T> extends PopupRoute<T> {
  GetDrawerRoute({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 300),
    RouteTransitionsBuilder? transitionBuilder,
  })  : widget = builder,
        // 点击模态是否可以关闭页面
        _barrierDismissible = barrierDismissible,
        // 模态颜色
        _barrierColor = barrierColor ?? Colors.transparent,
        _barrierLabel = barrierLabel,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder {
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  /// 弹出层显示的子 Widget
  final WidgetBuilder widget;

  /// 弹出层遮罩颜色，该属性返回null，即不设置遮罩颜色
  @override
  Color? get barrierColor => _barrierColor;
  final Color _barrierColor;

  /// 是否允许点击遮罩关闭弹出层，该属性返回true，即允许关闭
  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  /// 遮罩上显示的文本，该属性返回null，即不显示文本
  @override
  String? get barrierLabel => _barrierLabel;
  final String? _barrierLabel;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  /// 路由转换构建器
  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  void dispose() {
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: widget(context),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        ),
        child: child,
      );
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

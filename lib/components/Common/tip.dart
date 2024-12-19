import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, Obx;
import 'package:glidea/components/Common/visibility.dart';
import 'package:glidea/helpers/constants.dart';

// 工具提示控件
class TipWidget extends StatefulWidget {
  const TipWidget({
    super.key,
    this.message,
    this.richMessage,
    this.offset = Offset.zero,
    this.direction = AxisDirection.down,
    this.padding,
    this.style,
    this.decoration,
    required this.child,
  }) : assert((message == null) != (richMessage == null), 'TipWidget: `message` or `richMessage` must be specified');

  /// 提示出现在上方
  const TipWidget.up({
    super.key,
    required this.message,
    required this.child,
    this.offset = const Offset(0, -4),
    this.padding,
    this.style,
    this.decoration,
  })  : direction = AxisDirection.up,
        richMessage = null,
        assert(message != null, 'TipWidget: `message` or `richMessage` must be specified');

  /// 提示出现在下方
  const TipWidget.down({
    super.key,
    required this.message,
    required this.child,
    this.offset = const Offset(0, 4),
    this.padding,
    this.style,
    this.decoration,
  })  : direction = AxisDirection.down,
        richMessage = null,
        assert(message != null, 'TipWidget: `message` or `richMessage` must be specified');

  /// 提示出现在上方
  const TipWidget.left({
    super.key,
    required this.message,
    required this.child,
    this.offset = const Offset(-4, 0),
    this.padding,
    this.style,
    this.decoration,
  })  : direction = AxisDirection.left,
        richMessage = null,
        assert(message != null, 'TipWidget: `message` or `richMessage` must be specified');

  /// 提示出现在下方
  const TipWidget.right({
    super.key,
    required this.message,
    required this.child,
    this.offset = const Offset(4, 0),
    this.padding,
    this.style,
    this.decoration,
  })  : direction = AxisDirection.right,
        richMessage = null,
        assert(message != null, 'TipWidget: `message` or `richMessage` must be specified');

  /// 子控件
  final Widget child;

  /// 要显示在工具提示中的文本
  ///
  /// [message]和[richMessage]中只能有一个非空
  final String? message;

  /// 要在工具提示中显示的富文本
  ///
  /// [message]和[richMessage]中只能有一个非空
  final InlineSpan? richMessage;

  /// 偏移
  final Offset offset;

  /// 偏移的方向
  final AxisDirection direction;

  /// 提示的内边距
  final EdgeInsetsGeometry? padding;

  /// 文本样式
  final TextStyle? style;

  /// 指定工具提示的形状和背景颜色
  final Decoration? decoration;

  @override
  State<StatefulWidget> createState() => _TipWidgetState();
}

class _TipWidgetState extends State<TipWidget> {
  /// 判断是否悬浮
  final isHover = false.obs;

  /// [OverlayPortalController] 控制器
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void dispose() {
    isHover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 返回
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildTooltipOverlay,
      child: Semantics(
        tooltip: widget.message ?? widget.richMessage!.toPlainText(),
        child: InkWell(
          onTap: () {},
          onHover: onHover,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }

  /// 构建提示
  Widget _buildTooltipOverlay(BuildContext context) {
    final OverlayState overlayState = Overlay.of(context, debugRequiredFor: widget);
    final RenderBox box = this.context.findRenderObject()! as RenderBox;
    final Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    // 主题
    final theme = Get.theme;
    final tooltipTheme = theme.tooltipTheme;
    // 提示
    Widget childWidget = Obx(
      () => AnimatedVisibility(
        duration: const Duration(milliseconds: 200),
        visible: isHover.value,
        onEnd: onEnd,
        child: Semantics(
          container: true,
          child: Container(
            decoration: widget.decoration ?? tooltipTheme.decoration,
            padding: widget.padding ?? tooltipTheme.padding ?? (kVerPadding4 + kHorPadding8),
            child: Text.rich(
              widget.richMessage ?? TextSpan(text: widget.message),
              style: widget.style ?? tooltipTheme.textStyle,
            ),
          ),
        ),
      ),
    );

    // 需要使用 fill, 否则无法获取 Overlay 的大小
    return Positioned.fill(
      bottom: MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0.0,
      child: CustomSingleChildLayout(
        delegate: _TooltipPositionDelegate(
          target: target,
          targetSize: box.size,
          offset: widget.offset,
          direction: widget.direction,
        ),
        child: childWidget,
      ),
    );
  }

  /// 悬浮式调用
  void onHover(hover) {
    if (hover) {
      _overlayController.show();
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        isHover.value = true;
      });
    } else {
      isHover.value = false;
    }
  }

  void onEnd() {
    if (isHover.value) return;
    _overlayController.hide();
  }
}

class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  /// 创建用于计算工具提示布局的委托
  _TooltipPositionDelegate({
    required this.target,
    required this.targetSize,
    required this.offset,
    required this.direction,
  });

  /// 工具提示在全局坐标系中所靠近的目标的偏移量
  final Offset target;

  /// 目标的大小
  final Size targetSize;

  /// 目标与显示的工具提示之间的距离.
  final Offset offset;

  /// 同居提示的基础偏移的方向
  final AxisDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // target 的半个宽度
    final targetHalfWidth = targetSize.width / 2;
    // child 的半个宽度
    final childHalfWidth = childSize.width / 2;
    // 半个 target 宽度加上半个 child 宽度
    final halfWidget = childHalfWidth + targetHalfWidth;
    // child 的半个高度
    final childHalfHeight = childSize.height / 2;
    // 半个 target 高度加上半个 child 高度
    final halfHeight = childHalfHeight + (targetSize.height / 2);
    // x 中间位置
    var dx = target.dx - childHalfWidth;
    // y 中间位置
    var dy = target.dy - childHalfHeight;
    switch (direction) {
      case AxisDirection.up:
        // y 坐标
        dy -= halfHeight;
        break;
      case AxisDirection.down:
        // y 坐标
        dy += halfHeight;
        break;
      case AxisDirection.right:
        // x 坐标
        dx += halfWidget;
        break;
      case AxisDirection.left:
        // x 坐标
        dx -= halfWidget;
        break;
    }
    return Offset(dx, dy) + offset;
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate oldDelegate) {
    return target != oldDelegate.target || targetSize != oldDelegate.targetSize || offset != oldDelegate.offset || direction != oldDelegate.direction;
  }
}

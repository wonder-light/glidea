import 'package:flutter/foundation.dart' show DiagnosticPropertiesBuilder, FlagProperty, kDebugMode;
import 'package:flutter/material.dart';

/// Visibility 动画
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.visible,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 300),
    this.onEnd,
    this.child,
  });

  /// 在此容器的参数动画化时应用的曲线.
  final Curve curve;

  /// 此容器的参数动画化的持续时间
  final Duration duration;

  /// 控制控件是否可以的属性
  final bool visible;

  /// 每次动画完成时调用.
  ///
  /// 这对于在当前动画结束时触发附加动作（例如另一个动画）非常有用.
  final VoidCallback? onEnd;

  /// 树中此小部件下面的小部件
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _AnimatedVisibilityState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('visible', value: visible));
  }
}

class _AnimatedVisibilityState extends State<AnimatedVisibility> with SingleTickerProviderStateMixin<AnimatedVisibility> {
  /// 驱动这个小部件的隐式动画的动画控制器
  @protected
  AnimationController get controller => _controller;
  late final AnimationController _controller = AnimationController(
    value: getVisible(),
    duration: widget.duration,
    debugLabel: kDebugMode ? widget.toStringShort() : null,
    vsync: this,
  );

  /// 驱动这个小部件的隐式动画的动画
  Animation<double> get animation => _animation;
  late CurvedAnimation _animation = _createCurve();

  /// 记录当前透明度
  late final Tween<double> _opacity = Tween<double>();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((AnimationStatus status) {
      if (status.isCompleted) {
        widget.onEnd?.call();
      }
    });
    _controller.addListener(_handleChange);
    _updateOpacity();
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curve != oldWidget.curve) {
      _animation.dispose();
      _animation = _createCurve();
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (_shouldAnimateTween()) {
      _updateAnimateTween();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var visible = widget.visible || _shouldAnimateTween();
    return Visibility(
      visible: visible,
      child: Opacity(
        opacity: _animation.value,
        child: widget.child,
      ),
    );
  }

  /// 判断是否应该更新动画
  bool _shouldAnimateTween() {
    _updateOpacity();
    return _opacity.begin != _opacity.end;
  }

  /// 更新动画
  void _updateAnimateTween() {
    _controller.animateTo(_opacity.end!);
  }

  /// 创建曲线
  CurvedAnimation _createCurve() {
    return CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  /// 更新 _opacity 的值
  void _updateOpacity() {
    _opacity
      ..begin = _animation.value
      ..end = getVisible();
  }

  /// 获取 visible 对应的值
  double getVisible() => widget.visible ? 1 : 0;

  /// 用于刷新状态, 以此来更新属性
  void _handleChange() {
    if (!mounted) {
      return;
    }
    // listable的状态是我们的构建状态，它已经改变了
    setState(() {});
  }
}

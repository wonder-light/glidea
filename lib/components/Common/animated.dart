import 'package:flutter/material.dart';

/// 自动旋转的 animated 组件
class AutoAnimatedRotation extends StatefulWidget {
  const AutoAnimatedRotation({
    super.key,
    this.duration = const Duration(milliseconds: 600),
    this.onEnd,
    this.child,
  });

  /// 此容器的参数动画化的持续时间
  final Duration duration;

  /// 每次动画完成时调用.
  ///
  /// 这对于在当前动画结束时触发附加动作（例如另一个动画）非常有用
  final VoidCallback? onEnd;

  /// 树中此小部件下面的小部件
  final Widget? child;

  @override
  State<AutoAnimatedRotation> createState() => _AutoAnimatedRotationState();
}

class _AutoAnimatedRotationState extends State<AutoAnimatedRotation> with SingleTickerProviderStateMixin {
  /// 动画控制器
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
    animationBehavior: AnimationBehavior.preserve
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.child,
    );
  }
}

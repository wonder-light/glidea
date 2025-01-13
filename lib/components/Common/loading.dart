import 'dart:math' show Random, cos, pi, sin;

import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, this.maxSize = 80.0});

  /// 最大大小
  final double maxSize;

  @override
  State<LoadingWidget> createState() => _BallRotateChaseState();
}

class _BallRotateChaseState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  static const _durationInMills = 1500;
  static const _ballNum = 5;

  /// The index of shape in the widget.
  final int index = 0;
  late AnimationController _animationController;
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _translateAnimations = [];

  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );
    for (int i = 0; i < _ballNum; i++) {
      final rate = i / 5;
      final cubic = Cubic(0.5, 0.15 + rate, 0.25, 1.0);
      _scaleAnimations.add(Tween(begin: 1 - rate, end: 0.2 + rate).animate(CurvedAnimation(parent: _animationController, curve: cubic)));
      _translateAnimations.add(Tween(begin: 0.0, end: 2 * pi).animate(CurvedAnimation(parent: _animationController, curve: cubic)));

      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = widget.maxSize;

    final circleSize = maxWidth / 5;

    final deltaX = (maxWidth - circleSize) / 2;
    final deltaY = (maxWidth - circleSize) / 2;

    Widget child;
    List<Widget> widgets = [];
    // 圆圈
    for (int i = 0; i < _ballNum; i++) {
      child = Positioned.fromRect(
        rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(
                  deltaX * sin(_translateAnimations[i].value),
                  deltaY * -cos(_translateAnimations[i].value),
                ),

              /// scale must in child, if upper would align topLeft.
              child: ScaleTransition(
                scale: _scaleAnimations[i],
                child: child,
              ),
            );
          },
          /*child: IndicatorShapeWidget(
              shape: Shape.circle,
              index: i,
            ),*/
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            child: CustomPaint(
              painter: _ShapePainter(
                Colors.accents[Random().nextInt(16)],
                Shape.circle,
                null,
                2,
                pathColor: null,
              ),
            ),
          ),
        ),
      );
      widgets.add(child);
    }

    return Container(
      alignment: Alignment.center,
      width: maxWidth,
      height: maxWidth,
      child: Stack(alignment: Alignment.center, children: widgets),
    );
  }
}

/// Basic shape.
enum Shape {
  circle,
  ringThirdFour,
  rectangle,
  ringTwoHalfVertical,
  ring,
  line,
  triangle,
  arc,
  circleSemi,
}

class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Paint _paint;
  final double? data;
  final double strokeWidth;
  final Color? pathColor;

  _ShapePainter(
    this.color,
    this.shape,
    this.data,
    this.strokeWidth, {
    this.pathColor,
  })  : _paint = Paint()..isAntiAlias = true,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case Shape.circle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case Shape.ringThirdFour:
        if (pathColor != null) {
          _paint
            ..color = pathColor!
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2,
            _paint,
          );
        }
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.shortestSide / 2,
          ),
          -3 * pi / 4,
          3 * pi / 2,
          false,
          _paint,
        );
        break;
      case Shape.rectangle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, _paint);
        break;
      case Shape.ringTwoHalfVertical:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        final rect = Rect.fromLTWH(size.width / 4, size.height / 4, size.width / 2, size.height / 2);
        canvas.drawArc(rect, -3 * pi / 4, pi / 2, false, _paint);
        canvas.drawArc(rect, 3 * pi / 4, -pi / 2, false, _paint);
        break;
      case Shape.ring:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.shortestSide / 2, _paint);
        break;
      case Shape.line:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(size.shortestSide / 2)), _paint);
        break;
      case Shape.triangle:
        final offsetY = size.height / 4;
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        Path path = Path()
          ..moveTo(0, size.height - offsetY)
          ..lineTo(size.width / 2, size.height / 2 - offsetY)
          ..lineTo(size.width, size.height - offsetY)
          ..close();
        canvas.drawPath(path, _paint);
        break;
      case Shape.arc:
        assert(data != null);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, data!, pi * 2 - 2 * data!, true, _paint);
        break;
      case Shape.circleSemi:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, -pi * 6, -2 * pi / 3, false, _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      data != oldDelegate.data ||
      strokeWidth != oldDelegate.strokeWidth ||
      pathColor != oldDelegate.pathColor;
}

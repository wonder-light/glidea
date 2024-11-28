import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, RxT;

class NotfoundWidget extends StatefulWidget {
  const NotfoundWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NotfoundWidgetSate();
}

class _NotfoundWidgetSate extends State<StatefulWidget> {
  /// 颜色集合
  final colors = <Color>[].obs;

  /// [aligns] 当前使用的索引
  int index = 0;

  /// 确定 [begin] 是正向还是反向
  double forward = 1;

  /// [begin] 的方向值集合
  final aligns = [Alignment.centerLeft, Alignment.topLeft, Alignment.topCenter, Alignment.topRight];

  /// [aligns] 当前使用的方向
  final begin = Alignment.centerLeft.obs;

  /// 持续时间
  final duration = const Duration(seconds: 2);

  /// 时间句柄
  late Timer handle;

  @override
  void initState() {
    super.initState();
    colors.value = getColor();
    handle = Timer(duration * 0.05, update);
  }

  @override
  void dispose() {
    super.dispose();
    handle.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin.value,
            end: -begin.value,
            colors: colors.value,
          ),
        ),
        //curve: Curves.fastOutSlowIn,
      ),
    );
  }

  /// 获取随机颜色
  List<Color> getColor({int num = 5}) {
    final random = Random();
    return [
      for (var i = 0; i < num; ++i)
        Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ),
    ];
  }

  /// 更新颜色和方向
  void update() {
    if (++index >= aligns.length) {
      forward *= -1;
      index = 0;
    }
    begin.value = aligns[index] * forward;
    colors.value = getColor();
    handle = Timer(duration, update);
  }
}

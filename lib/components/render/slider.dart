import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx;
import 'package:glidea/models/render.dart';

import 'base.dart';

class SliderWidget extends ConfigBaseWidget<SliderConfig, double> {
  const SliderWidget({
    super.key,
    required super.config,
    super.isTop,
    super.ratio,
    super.labelPadding,
    super.contentPadding,
    super.onChanged,
  });

  @override
  Widget buildContent(BuildContext context, ThemeData theme) {
    return SliderTheme(
      data: const SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
        //  滑块形状，可以自定义
        /*thumbShape: RoundSliderThumbShape(
          // 滑块大小
          enabledThumbRadius: 10,
        ),*/
        // thumbColor: Colors.white, // 滑块颜色
        // 滑块外圈形状，可以自定义
        overlayShape: RoundSliderOverlayShape(
          // 滑块外圈大小
          overlayRadius: 16,
        ),
      ),
      child: Slider(
        min: 0,
        max: config.max,
        value: config.value,
        //divisions: config.max.toInt(),
        label: config.value.toStringAsFixed(1),
        onChanged: onChanged,
      ),
    );
  }
}

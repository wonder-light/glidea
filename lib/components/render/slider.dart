import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx;
import 'package:glidea/models/render.dart';

import 'base.dart';

class SliderWidget extends ConfigBaseWidget<SliderConfig> {
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
      child: Obx(() {
        var isInt = config.value.isInt;
        var maxValue = config.value.max;
        var currentValue = config.value.value;
        return Slider(
          min: 0.0,
          max: isInt ? maxValue.ceilToDouble() : maxValue,
          value: isInt ? currentValue.floorToDouble() : currentValue,
          divisions: isInt ? maxValue.ceil() : null,
          label: config.value.value.toStringAsFixed(isInt ? 0 : 1),
          onChanged: (value) {
            config.update((t) {
              t!.value = value;
              return t;
            });
            onChanged?.call(value);
          },
        );
      }),
    );
  }
}

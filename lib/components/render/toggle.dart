import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx;
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';

/// 主题设置中的开关控件
class ToggleWidget extends ConfigBaseWidget<ToggleConfig> {
  const ToggleWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: Obx(
        () => Switch(
          value: config.value.value,
          onChanged: change,
          trackOutlineWidth: WidgetStateProperty.all(0),
          thumbIcon: WidgetStateProperty.resolveWith<Icon>((states) {
            if (states.contains(WidgetState.selected)) {
              return const Icon(PhosphorIconsRegular.check);
            }
            return const Icon(PhosphorIconsRegular.x);
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  /// 开关值变化时调用
  void change(bool value) {
    config.update((obj) => obj!..value = value);
    onChanged?.call(value);
  }
}

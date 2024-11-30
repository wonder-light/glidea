import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx;
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';

class ToggleWidget extends ConfigBaseWidget<ToggleConfig> {
  const ToggleWidget({
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
    return Theme(
      data: theme,
      child: Obx(
        () => Switch(
          value: config.value.value,
          onChanged: (onOff) {
            config.update((obj) {
              return obj!..value = onOff;
            });
            onChanged?.call(onOff);
          },
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
}

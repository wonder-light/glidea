import 'package:flutter/material.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';

class ToggleWidget extends ConfigBaseWidget<ToggleConfig, bool> {
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
      child: Switch(
        value: config.value,
        onChanged: onChanged,
        trackOutlineWidth: WidgetStateProperty.all(0),
        thumbIcon: WidgetStateProperty.resolveWith<Icon>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(PhosphorIconsRegular.check);
          }
          return const Icon(PhosphorIconsRegular.x);
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

class RadioWidget extends ConfigBaseWidget<RadioConfig, String?> {
  const RadioWidget({
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
    var index = 0;
    var length = config.options.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var item in config.options)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio(value: item.value, groupValue: config.value, onChanged: onChanged),
              Text(item.label.tr),
              if (++index < length) const Padding(padding: kRightPadding16),
            ],
          ),
      ],
    );
  }
}

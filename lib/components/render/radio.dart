import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

class RadioWidget extends ConfigBaseWidget<RadioConfig> {
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
    var length = config.value.options.length;
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var item in config.value.options)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: item.value,
                  groupValue: config.value.value,
                  onChanged: (str) {
                    config.update((obj) {
                      return obj!..value = str ?? obj.value;
                    });
                    onChanged?.call(str);
                  },
                ),
                Text(item.label.tr),
                if (++index < length) const Padding(padding: kRightPadding16),
              ],
            ),
        ],
      ),
    );
  }
}

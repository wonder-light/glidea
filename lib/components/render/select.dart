import 'package:dropdown_button2/dropdown_button2.dart' show DropdownButtonFormField2, MenuItemStyleData, ButtonStyleData;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

class SelectWidget extends ConfigBaseWidget<SelectConfig, String?> {
  const SelectWidget({
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
    return DropdownButtonFormField2(
      value: config.value,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
        //hintText: config.note.tr,
        hintStyle: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: kHorPadding16,
      ),
      buttonStyleData: const ButtonStyleData(
        width: 0,
        padding: EdgeInsets.zero,
      ),
      items: [
        for (var option in config.options)
          DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label.tr),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

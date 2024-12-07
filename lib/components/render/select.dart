import 'package:dropdown_button2/dropdown_button2.dart' show ButtonStyleData, DropdownButtonFormField2, DropdownStyleData, MenuItemStyleData;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

/// 主题设置中的下拉选择按钮控件
class SelectWidget extends ConfigBaseWidget<SelectConfig> {
  const SelectWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Get.theme;
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: DropdownButtonFormField2(
        value: config.value.value,
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
        dropdownStyleData: const DropdownStyleData(
          isOverButton: false,
          useRootNavigator: true,
        ),
        items: [
          for (var option in config.value.options)
            DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label.tr),
            ),
        ],
        onChanged: change,
      ),
    );
  }

  /// 下拉选择按钮的值变化时调用
  void change(String? value) {
    config.update((obj) => obj..value = value ?? obj.value);
    onChanged?.call(value);
  }
}

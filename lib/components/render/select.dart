import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Trans;
import 'package:glidea/components/Common/dropdown.dart';
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
    this.bottomItem,
  });

  /// 在弹出菜单底部显示的控件
  final DropdownMenuItem<String>? bottomItem;

  @override
  Widget build(BuildContext context) {
    var theme = Get.theme;
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: DropdownWidget(
        initValue: config.value.value,
        itemHeight: 40,
        itemPadding: kHorPadding16,
        bottomItem: bottomItem,
        onSelected: change,
        children: [
          for (var option in config.value.options)
            DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label.tr, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }

  /// 下拉选择按钮的值变化时调用
  void change(String? value) {
    config.update((obj) => obj..value = value ?? obj.value);
    onChanged?.call(value);
  }
}

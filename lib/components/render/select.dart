import 'package:flutter/material.dart';
import 'package:flutter_js/quickjs/ffi.dart';
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
  final DropdownMenuItem<SelectOption>? bottomItem;

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final entry = config.value;
    final initValue = entry.options.firstWhereOrNull((t) => t.value == entry.value);
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: DropdownWidget<SelectOption>(
        initValue: initValue,
        itemHeight: 40,
        itemPadding: kHorPadding16,
        bottomItem: bottomItem,
        onSelected: change,
        displayStringForItem: (item) => item.label,
        children: [
          for (var option in config.value.options)
            DropdownMenuItem(
              value: option,
              child: Text(option.label.tr, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }

  /// 下拉选择按钮的值变化时调用
  void change(SelectOption item) {
    config.update((obj) => obj..value = item.value);
    onChanged?.call(item);
  }
}

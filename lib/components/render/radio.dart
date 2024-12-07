import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

/// 主题设置中的单选框控件
class RadioWidget extends ConfigBaseWidget<RadioConfig> {
  const RadioWidget({
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
      child: Obx(() {
        // 索引
        var index = 0;
        // 当前选中的值
        var groupValue = config.value.value;
        // 数量
        var length = config.value.options.length;
        // 控件列表
        List<Widget> lists = [];
        for (var item in config.value.options) {
          lists.add(Radio(value: item.value, groupValue: groupValue, onChanged: change));
          lists.add(Text(item.label.tr));
          // 间距
          if (++index < length) {
            lists.add(const Padding(padding: kRightPadding16));
          }
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: lists,
        );
      }),
    );
  }

  /// 单选框的值变化时调用
  void change(String? value) {
    config.update((obj) => obj..value = value ?? obj.value);
    onChanged?.call(value);
  }
}

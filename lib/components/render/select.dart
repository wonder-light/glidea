import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

class SelectWidget extends StatelessWidget {
  const SelectWidget({
    super.key,
    required this.select,
    this.onChanged,
    this.labelPadding,
    this.ratio = 2,
  });

  /// 下拉列表配置
  final SelectConfig select;

  /// 当用户选择一项时调用。
  final ValueChanged<String?>? onChanged;

  final EdgeInsetsGeometry? labelPadding;

  /// 比率: ratio = select / text
  final double ratio;

  @override
  Widget build(BuildContext context) {
    const base = 100;
    Widget childWidget = DropdownButtonFormField2(
      value: select.value,
      hint: Text(select.note.tr),
      isDense: true,
      isExpanded: true,
      decoration: kInputDecoration,
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: kHorizontalPadding,
      ),
      buttonStyleData: const ButtonStyleData(
        width: 0,
        padding: EdgeInsets.zero,
      ),
      items: [
        for (var option in select.options)
          DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label.tr),
          ),
      ],
      onChanged: onChanged,
    );
    childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
            flex: base,
            child: Padding(
              padding: labelPadding ?? kLabelPadding,
              child: Text(select.label),
            )),
        Flexible(
          flex: (ratio * base).ceil(),
          child: childWidget,
        ),
        Flexible(
          flex: base,
          child: Container(),
        ),
      ],
    );
    return childWidget;
  }
}

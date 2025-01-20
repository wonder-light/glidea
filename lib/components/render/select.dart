part of 'base.dart';

/// 主题设置中的下拉选择按钮控件
class SelectWidget extends BaseRenderWidget<SelectConfig> {
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
  Widget buildContent(BuildContext context) {
    final bodyMedium = TextTheme.of(context).bodyMedium;
    final entry = config.value;
    final initValue = entry.options.firstWhereOrNull((t) => t.value == entry.value);
    return DropdownWidget<SelectOption>(
      initValue: initValue,
      itemHeight: 40,
      itemPadding: kHorPadding16,
      bottomItem: bottomItem,
      onSelected: change,
      displayStringForItem: (item) => item.label,
      children: [
        for (var option in entry.options)
          DropdownMenuItem(
            value: option,
            child: Text(option.label.tr, style: bodyMedium),
          ),
      ],
    );
  }

  /// 下拉选择按钮的值变化时调用
  void change(SelectOption item) {
    config.update((obj) => obj..value = item.value);
    onChanged?.call(item.value);
  }
}

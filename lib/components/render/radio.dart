part of 'base.dart';

/// 主题设置中的单选框控件
class RadioWidget extends BaseRenderWidget<RadioConfig> {
  const RadioWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      // 索引
      var index = 0;
      final entry = config.value;
      // 数量
      var length = entry.options.length;
      // 控件列表
      List<Widget> lists = [];
      for (var item in entry.options) {
        lists.add(Radio(value: item.value, groupValue: entry.value, onChanged: change));
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
    });
  }

  /// 单选框的值变化时调用
  void change(String? value) {
    config.update((obj) => obj..value = value ?? obj.value);
    onChanged?.call(value);
  }
}

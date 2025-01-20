part of 'base.dart';

/// 主题设置中的滑块控件
class SliderWidget extends BaseRenderWidget<SliderConfig> {
  const SliderWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Obx(() {
      var maxValue = config.value.max;
      var currentValue = config.value.value;
      return Slider(
        min: config.value.min.floorToDouble(),
        max: maxValue.ceilToDouble(),
        value: currentValue.floorToDouble(),
        divisions: maxValue.ceil(),
        label: currentValue.toString(),
        onChanged: change,
      );
    });
  }

  /// 滑块值变化时调用
  void change(double value) {
    var index = value.toInt();
    config.update((obj) => obj..value = index);
    onChanged?.call(index);
  }
}

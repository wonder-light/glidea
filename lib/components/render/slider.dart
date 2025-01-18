part of 'base.dart';

/// 主题设置中的滑块控件
class SliderWidget extends ConfigBaseWidget<SliderConfig> {
  const SliderWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  /// 指定后代滑块小部件的颜色和形状值。
  static const SliderThemeData _sliderData = SliderThemeData(
    showValueIndicator: ShowValueIndicator.always,
    //  滑块形状，可以自定义
    /*thumbShape: RoundSliderThumbShape(
          // 滑块大小
          enabledThumbRadius: 10,
        ),*/
    // thumbColor: Colors.white, // 滑块颜色
    // 滑块外圈形状，可以自定义
    overlayShape: RoundSliderOverlayShape(
      // 滑块外圈大小
      overlayRadius: 16,
    ),
  );

  @override
  Widget buildContent(BuildContext context) {
    return SliderTheme(
      data: _sliderData,
      child: Obx(() {
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
      }),
    );
  }

  /// 滑块值变化时调用
  void change(double value) {
    var index = value.toInt();
    config.update((obj) => obj..value = index);
    onChanged?.call(index);
  }
}

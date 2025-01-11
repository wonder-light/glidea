part of 'base.dart';

/// 主题设置中的开关控件
class ToggleWidget extends ConfigBaseWidget<ToggleConfig> {
  const ToggleWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  /// 这个[开关]轨道的轮廓宽度
  static final WidgetStateProperty<double?> _trackOutlineWidth = WidgetStateProperty.all(0);

  /// 在这个开关的 thumb 上使用的图标
  static final WidgetStateProperty<Icon?> _thumbIcon = WidgetStateProperty.resolveWith<Icon>((states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(PhosphorIconsRegular.check);
    }
    return const Icon(PhosphorIconsRegular.x);
  });

  @override
  Widget buildContent(BuildContext context) {
    return Obx(
      () => Switch(
        value: config.value.value,
        onChanged: change,
        trackOutlineWidth: _trackOutlineWidth,
        thumbIcon: _thumbIcon,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// 开关值变化时调用
  void change(bool value) {
    config.update((obj) => obj..value = value);
    onChanged?.call(value);
  }
}

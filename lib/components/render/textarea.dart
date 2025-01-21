part of 'base.dart';

/// 主题设置中的富文本控件
class TextareaWidget<T extends TextareaConfig> extends BaseRenderWidget<T> {
  TextareaWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    TextEditingController? controller,
    this.inputFormatters,
  }) : controller = controller ?? TextEditingController(text: config.value.value);

  /// text 控制器
  final TextEditingController controller;

  /// 输入格式化
  final List<TextInputFormatter>? inputFormatters;

  /// 是否时富文本
  bool get isTextarea => true;

  /// 文本框是否只读
  bool get isReadOnly => false;

  /// 隐藏密码吗
  bool get hidePassword => false;

  @override
  Widget buildContent(BuildContext context) {
    final theme = Theme.of(Get.context!);
    return Obx(
      () => TextFormField(
        obscureText: hidePassword,
        controller: controller,
        readOnly: isReadOnly,
        minLines: isTextarea ? 2 : null,
        maxLines: isTextarea ? 30 : 1,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: kVer8Hor12,
          hoverColor: Colors.transparent,
          prefixIcon: getPrefixIcon(),
          suffixIcon: getSuffixIcon(),
          prefixIconConstraints: const BoxConstraints(),
          suffixIconConstraints: const BoxConstraints(),
          hintText: config.value.hint.tr,
          hintStyle: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.outline),
        ),
        onChanged: change,
        inputFormatters: inputFormatters,
      ),
    );
  }

  /// 内容值变化时调用
  void change(String value) {
    config.value.value = value;
    onChanged?.call(value);
  }

  /// 获取输入框的前缀按钮
  Widget? getPrefixIcon() => null;

  /// 获取输入框的后缀按钮
  Widget? getSuffixIcon() => null;
}

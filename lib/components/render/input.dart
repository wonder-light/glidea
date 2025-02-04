part of 'base.dart';

/// 主题设置中的文本控件
class InputWidget extends TextareaWidget<InputConfig> {
  InputWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    super.controller,
    super.inputFormatters,
    this.prefixIcon,
    this.usePassword,
  }) {
    config.value.hidePassword = usePassword ?? false;
  }

  /// 在装饰的容器中, 出现在文本字段的可编辑部分之后和后缀或 suffixText 之后的图标
  final Widget? prefixIcon;

  /// 使用密码样式
  ///
  /// ```
  /// true:  使用隐藏密码
  /// ```
  final bool? usePassword;

  @override
  bool get hidePassword => config.value.hidePassword;

  @override
  bool get isTextarea => false;

  @override
  bool get isReadOnly => config.value.card != InputCardType.none;

  @override
  Widget? getPrefixIcon() {
    final obj = config.value;
    return switch (obj.card) {
      InputCardType.post => IconButton(
          color: ColorScheme.of(Get.context!).primary,
          icon: const Icon(PhosphorIconsRegular.article),
          onPressed: postDialog,
        ),
      InputCardType.color => IconButton(
          color: obj.value.toColorFromCss,
          icon: const Icon(PhosphorIconsRegular.palette),
          onPressed: colorDialog,
        ),
      _ => prefixIcon,
    };
  }

  @override
  Widget? getSuffixIcon() {
    final obj = config.value;
    if (obj.card != InputCardType.none || usePassword != true) return null;
    // 密码
    return IconButton(
      icon: obj.hidePassword ? const Icon(PhosphorIconsRegular.eyeSlash) : const Icon(PhosphorIconsRegular.eye),
      onPressed: () {
        config.update((obj) => obj..hidePassword = !obj.hidePassword);
      },
    );
  }

  /// 文章选择弹窗
  void postDialog() {
    final site = Get.find<SiteController>(tag: SiteController.tag);
    final theme = Theme.of(Get.context!);
    // 数据
    final links = site.getPostLink();
    // 高度
    final constraints = const BoxConstraints(maxHeight: 60);
    // 子标题样式
    final subtitleTextStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);
    // 列表
    Widget childWidget = ListView.separated(
      shrinkWrap: true,
      itemCount: links.length,
      itemBuilder: (BuildContext context, int index) {
        final option = links[index];
        return ListItem(
          dense: true,
          constraints: constraints,
          title: Text(option.name),
          subtitle: Text(option.link),
          subtitleTextStyle: subtitleTextStyle,
          leadingMargin: kRightPadding16,
          leading: const Icon(PhosphorIconsRegular.link),
          onTap: () {
            controller.text = config.value.value = option.link;
            Get.backLegacy();
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, thickness: 1),
    );
    // 约束
    childWidget = Container(
      padding: kHorPadding16,
      width: kPanelWidth * 0.8,
      height: kPanelWidth * 1.1,
      child: childWidget,
    );
    // 弹窗
    _showDialog(Tran.selectArticle, childWidget);
  }

  /// 颜色选择器弹窗
  void colorDialog() {
    // 颜色选择器
    Widget childWidget = ColorPicker(
      width: 26,
      color: config.value.value.toColorFromCss,
      pickersEnabled: const {
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      enableShadesSelection: false,
      enableOpacity: true,
      onColorChanged: (Color color) {},
      onColorChangeEnd: (Color color) {
        config.update((obj) => obj..value = controller.text = '#${color.toCssHex}');
      },
    );
    // 弹窗
    _showDialog(Tran.selectColor, childWidget);
  }

  /// 显示弹窗
  void _showDialog(String title, Widget child) {
    // 显示弹窗控件
    Get.dialog(DialogWidget(
      header: Padding(
        padding: kAllPadding16,
        child: Text(title.tr, textScaler: const TextScaler.linear(1.2)),
      ),
      content: child,
      actions: const Padding(padding: kTopPadding16),
      onCancel: () => Get.backLegacy(),
      onConfirm: () => Get.backLegacy(),
    ));
  }
}

/// 文件夹选择器控件
class FileSelectWidget extends TextareaWidget<InputConfig> {
  FileSelectWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    bool isReadOnly = true,
  }) : _isReadOnly = isReadOnly;

  @override
  bool get isTextarea => false;

  @override
  bool get isReadOnly => _isReadOnly;
  final bool _isReadOnly;

  @override
  Widget? getSuffixIcon() {
    return IconButton(
      icon: const Icon(PhosphorIconsRegular.folderOpen),
      onPressed: selectFile,
    );
  }

  /// 选择文件夹
  void selectFile() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    controller.text = config.value.value = FS.normalize(selectedDirectory);
  }
}

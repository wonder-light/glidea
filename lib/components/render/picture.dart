﻿part of 'base.dart';

class PictureWidget extends BaseRenderWidget<PictureConfig> {
  const PictureWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    this.scope = -1,
    this.constraints,
  });

  /// 限定范围
  ///
  ///     > 0  => 主题
  ///     = 0  => 自定义主题
  ///     < 0  => 其它
  final int scope;

  /// 设置图片大小
  final BoxConstraints? constraints;

  /// 图片默认大小
  static const BoxConstraints _customImage = BoxConstraints(
    minWidth: kImageWidth / 1.5,
    maxWidth: kImageWidth,
    maxHeight: kImageWidth * 2,
  );

  /// 主题配置图片默认大小
  static const BoxConstraints _themeImage = BoxConstraints(
    minWidth: kImageWidth / 3,
    maxWidth: kImageWidth / 2,
    maxHeight: kImageWidth,
  );

  /// 图片的按钮样式
  static final ButtonStyle _buttonStyle = ButtonStyle(
    enableFeedback: true,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: WidgetStateProperty.all(kAllPadding16 / 2),
    shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6)))),
    side: WidgetStateProperty.resolveWith((states) {
      final colorScheme = ColorScheme.of(Get.context!);
      final color = states.contains(WidgetState.hovered) ? colorScheme.outline : colorScheme.outlineVariant;
      return BorderSide(color: color, width: 0.4);
    }),
  );

  @override
  Widget buildContent(BuildContext context) {
    /// 站点控制器
    final site = Get.find<SiteController>(tag: SiteController.tag);
    // 值
    final img = config.value;
    // 文件夹
    if (img.folder.isEmpty) {
      img.folder = switch (scope) {
        == 0 => FS.join(site.state.appDir, 'themes', site.themeConfig.selectTheme, 'assets'),
        _ => site.state.appDir,
      };
    }
    // 文件路径
    if (img.filePath.isEmpty) {
      img.filePath = img.value.isEmpty ? '' : FS.join(img.folder, img.value);
    }
    // 边距
    final cons = switch (scope) {
      > 0 => _themeImage,
      == 0 => _customImage,
      _ => const BoxConstraints(),
    };
    // 控件
    return OutlinedButton(
      onPressed: changeImage,
      style: _buttonStyle,
      child: ConstrainedBox(
        constraints: constraints ?? cons,
        child: Obx(() => ImageConfig.builderImg(config.value.filePath, fit: BoxFit.contain)),
      ),
    );
  }

  /// 改变图片
  void changeImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: imageExt,
    );
    if (result?.paths.firstOrNull?.isEmpty ?? true) return;
    // 选择的图片路径
    config.update((obj) => obj..filePath = FS.normalize(result!.paths.first!));
    onChanged?.call(config.value.filePath);
  }
}

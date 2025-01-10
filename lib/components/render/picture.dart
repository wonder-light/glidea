import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxString, StringExtension;
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

class PictureWidget extends ConfigBaseWidget<PictureConfig> {
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
  static const BoxConstraints _imageConstraints = BoxConstraints(
    minWidth: kImageWidth / 1.5,
    maxWidth: kImageWidth,
    maxHeight: kImageWidth * 2,
  );

  @override
  Widget build(BuildContext context) {
    /// 站点控制器
    final site = Get.find<SiteController>(tag: SiteController.tag);
    // 颜色
    final colorScheme = Get.theme.colorScheme;
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
    // 设置初始路径
    final path = img.filePath.obs;
    // 控件
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: OutlinedButton(
        onPressed: () => changeImage(path),
        style: ButtonStyle(
          enableFeedback: true,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: WidgetStateProperty.all(kAllPadding16 / 2),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            var color = states.contains(WidgetState.hovered) ? colorScheme.outline : colorScheme.outlineVariant;
            return BorderSide(color: color, width: 0.4);
          }),
        ),
        child: ConstrainedBox(
          constraints: constraints ?? (scope < 0 ? const BoxConstraints() : _imageConstraints),
          child: Obx(() => ImageConfig.builderImg(path.value, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  /// 改变图片
  void changeImage(RxString path) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: imageExt,
    );
    if (result?.paths.firstOrNull?.isEmpty ?? true) return;
    // 选择的图片路径
    path.value = FS.normalize(result!.paths.first!);
    config.value.filePath = path.value;
    onChanged?.call(path.value);
  }
}

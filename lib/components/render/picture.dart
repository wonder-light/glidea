import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxString, StringExtension;
import 'package:glidea/controller/site.dart';
import 'package:glidea/controller/theme.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/models/render.dart';
import 'package:image/image.dart' as img show decodeImageFile;

import 'base.dart';

/// 主题设置中的图片控件
class PictureWidget extends ConfigBaseWidget<PictureConfig> {
  const PictureWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 颜色
    final colorScheme = Get.theme.colorScheme;
    // 站点控制器
    final site = Get.find<SiteController>(tag: SiteController.tag);
    // 主题控件器
    final ctr = Get.find<ThemeController>(tag: site.themeCurrentTag);
    // 初始图片路径
    final initPath = FS.joinR(site.state.appDir, ctr.pathDir, config.value.value);
    // 当前图片路径
    final path = initPath.obs;
    // 绑定事件, 以路径作为 id, 防止重复
    site.once(themeSaveEvent, (_) => saveImage(initPath, path), id: initPath, cover: true);
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
          constraints: const BoxConstraints(
            minWidth: kImageWidth / 1.5,
            maxWidth: kImageWidth,
            maxHeight: kImageWidth * 2,
          ),
          child: Obx(
            () => Image(
              image: FileImageExpansion.file(path.value),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  /// 改变图片
  void changeImage(RxString path) async {
    /*
    //实例化选择图片
    final picker = ImagePicker();
    //选择相册
    final pickerImages = await picker.pickImage(source: ImageSource.gallery);
    if (pickerImages == null || pickerImages.path.isEmpty) return;
    */
    //实例化选择图片
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'webp', 'gif', 'tif', 'tiff', 'apng'],
    );
    if (result == null || result.paths.firstOrNull == null || result.paths.first!.isEmpty) return;
    // 选择的图片路径
    path.value = FS.normalize(result.paths.first!);
  }

  /// 保存图片
  ///
  /// [init] 初始路径
  ///
  /// [current] 当前显示的图片的路径
  Future<void> saveImage(String init, RxString current) async {
    // 保存并压缩
    var image = await img.decodeImageFile(current.value);
    await image?.compressImage(init);
    // 恢复原有的路径
    current.value = init;
  }
}

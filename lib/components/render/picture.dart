import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx, RxString, StringExtension;
import 'package:glidea/controller/site.dart';
import 'package:glidea/controller/theme.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/render.dart';
import 'package:image/image.dart' as img show decodeImageFile;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

import 'base.dart';

class PictureWidget extends ConfigBaseWidget<PictureConfig> {
  const PictureWidget({
    super.key,
    required super.config,
    super.isTop,
    super.ratio,
    super.labelPadding,
    super.contentPadding,
    super.onChanged,
  });


  @override
  Widget buildContent(BuildContext context, ThemeData theme) {
    var site = Get.find<SiteController>(tag: SiteController.tag);
    var ctr = Get.find<ThemeController>(tag: site.themeCurrentTag);
    final path = FS.joinR(site.state.appDir, ctr.pathDir, config.value.value).obs;
    Log.i(path);
    return Obx(
      () => OutlinedButton(
        onPressed: () => getImage(site, path),
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
            var color = states.contains(WidgetState.hovered) ? theme.colorScheme.outline : theme.colorScheme.outlineVariant;
            return BorderSide(color: color, width: 0.4);
          }),
        ),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: kImageWidth / 1.5,
            maxWidth: kImageWidth,
            maxHeight: kImageWidth * 2,
          ),
          child: Image(
            image: FileImageExpansion(File(path.value)),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void getImage(SiteController site, RxString path) async {
    //实例化选择图片
    final picker = ImagePicker();
    //选择相册
    final pickerImages = await picker.pickImage(source: ImageSource.gallery);
    if (pickerImages == null || pickerImages.path.isEmpty) return;
    // 保存的目标路径
    var target = path.value;
    // 选择的图片路径
    path.value = FS.normalize(pickerImages.path);

    /// 保存图片
    Future<void> saveImage(arg) async {
      // 保存并压缩
      var image = await img.decodeImageFile(path.value);
      await image?.compressImage(target);
      //await pickerImages.saveTo(target);
      // 恢复原有的路径
      path.value = target;
    }

    site.once(themeSaveEvent, saveImage);
  }
}

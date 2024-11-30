import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx;
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/models/render.dart';

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
    return Obx(
      () => OutlinedButton(
        onPressed: () {
          // TODO: 打开图片选择器
        },
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
            maxWidth: 300,
            maxHeight: 400,
          ),
          child: Image.file(
            File(FS.joinR(site.state.appDir, config.value.value)),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

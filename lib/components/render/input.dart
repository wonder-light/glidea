import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/color.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';

class TextareaWidget extends ConfigBaseWidget<TextareaConfig, String> {
  const TextareaWidget({
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
    return TextFormField(
      initialValue: config.value,
      minLines: 2,
      maxLines: 30,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent,
        hintText: config.hint.tr,
        hintStyle: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class InputWidget extends ConfigBaseWidget<InputConfig, String> {
  const InputWidget({
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
    Widget? button = switch (config.card) {
      InputCardType.post => IconButton(
          color: theme.colorScheme.primary,
          icon: const Icon(PhosphorIconsRegular.article),
          onPressed: postDialog,
        ),
      InputCardType.card => IconButton(
          color: config.value.toColorFromCss,
          icon: const Icon(PhosphorIconsRegular.palette),
          onPressed: colorDialog,
        ),
      _ => null,
    };

    return TextFormField(
      initialValue: config.value,
      readOnly: config.card != InputCardType.none,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent,
        prefixIcon: button,
        hintText: config.hint.tr,
        hintStyle: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      onChanged: onChanged,
    );
  }

  /// 文章选择弹窗
  void postDialog() {
    final site = Get.find<SiteController>(tag: SiteController.tag);
    // 数据
    var links = site.getPostLink();
    // 列表
    var index = 0;
    Widget childWidget = Column(
      children: [
        for (var option in links) ...[
          if (index++ > 0) const Divider(height: 1, thickness: 1),
          ListItem(
            leading: const Icon(PhosphorIconsRegular.link),
            onTap: () {
              onChanged?.call(option.link);
              Get.backLegacy();
            },
            title: Text(option.name),
            subtitle: Text(option.link),
            dense: true,
          ),
        ],
      ],
    );
    // 约束
    childWidget = Container(
      padding: kHorPadding16,
      constraints: const BoxConstraints(maxHeight: kPanelWidth * 1.4),
      child: SingleChildScrollView(
        child: childWidget,
      ),
    );
    // 弹窗控件
    childWidget = DialogWidget(
      header: Padding(
        padding: kAllPadding16,
        child: Text('selectArticle'.tr, textScaler: const TextScaler.linear(1.2)),
      ),
      content: childWidget,
      actions: const Padding(padding: kTopPadding16),
      onCancel: () {
        Get.backLegacy();
      },
      onConfirm: () {
        Get.backLegacy();
      },
    );
    // 弹窗
    Get.dialog(childWidget);
  }

  /// 颜色选择器弹窗
  void colorDialog() {
    // 颜色选择器
    Widget childWidget = ColorPicker(
      width: 26,
      pickersEnabled: const {
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      enableShadesSelection: false,
      enableOpacity: true,
      onColorChanged: (Color color) {},
      onColorChangeEnd: (Color color) {
        onChanged?.call(color.toCssHex);
        //onSelected(color.toCssHex);
      },
    );
    // 弹窗控件
    childWidget = DialogWidget(
      header: Padding(
        padding: kAllPadding16,
        child: Text('selectColor'.tr, textScaler: const TextScaler.linear(1.2)),
      ),
      content: childWidget,
      actions: const Padding(padding: kTopPadding16),
      onCancel: () {
        Get.backLegacy();
      },
      onConfirm: () {
        Get.backLegacy();
      },
    );
    // 弹窗
    Get.dialog(childWidget);
  }
}

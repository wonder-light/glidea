import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flex_color_picker/flex_color_picker.dart' show ColorPicker, ColorPickerType;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, RxBool, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/color.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';

/// 主题设置中的富文本控件
class TextareaWidget<T extends TextareaConfig> extends ConfigBaseWidget<T> {
  const TextareaWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    this.controller,
    this.inputFormatters,
  });

  /// text 控制器
  final TextEditingController? controller;

  /// 输入格式化
  final List<TextInputFormatter>? inputFormatters;

  /// 是否时富文本
  bool get isTextarea => true;

  /// 文本框是否只读
  bool get isReadOnly => false;

  /// 隐藏密码吗
  bool get hidePassword => false;

  @override
  Widget build(BuildContext context) {
    var theme = Get.theme;
    final controller = this.controller ?? TextEditingController();
    if (this.controller == null) {
      controller.text = config.value.value;
    }
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: Obx(() {
        return TextFormField(
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
            hintStyle: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          onChanged: change,
          inputFormatters: inputFormatters,
        );
      }),
    );
  }

  /// 内容值变化时调用
  void change(String value) {
    config.update((obj) => obj..value = value);
    onChanged?.call(value);
  }

  /// 获取输入框的前缀按钮
  Widget? getPrefixIcon() => null;

  /// 获取输入框的后缀按钮
  Widget? getSuffixIcon() => null;
}

/// 主题设置中的文本控件
class InputWidget extends TextareaWidget<InputConfig> {
  const InputWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
    super.controller,
    super.inputFormatters,
    this.prefixIcon,
    this.usePassword,
  });

  /// 在装饰的容器中, 出现在文本字段的可编辑部分之后和后缀或 suffixText 之后的图标
  final Widget? prefixIcon;

  /// 使用密码样式
  ///
  /// ```
  /// null:  不使用密码
  /// true:  隐藏密码
  /// false: 显示密码
  /// ```
  final RxBool? usePassword;

  @override
  bool get hidePassword => usePassword?.value ?? false;

  @override
  bool get isTextarea => false;

  @override
  bool get isReadOnly => config.value.card != InputCardType.none;

  @override
  Widget? getPrefixIcon() {
    var theme = Get.theme;
    return switch (config.value.card) {
      InputCardType.post => IconButton(
          color: theme.colorScheme.primary,
          icon: const Icon(PhosphorIconsRegular.article),
          onPressed: postDialog,
        ),
      InputCardType.card => IconButton(
          color: config.value.value.toColorFromCss,
          icon: const Icon(PhosphorIconsRegular.palette),
          onPressed: colorDialog,
        ),
      _ => prefixIcon,
    };
  }

  @override
  Widget? getSuffixIcon() {
    if (config.value.card == InputCardType.none && usePassword != null) {
      return IconButton(
        icon: hidePassword ? const Icon(PhosphorIconsRegular.eyeSlash) : const Icon(PhosphorIconsRegular.eye),
        onPressed: () {
          assert(usePassword != null, 'InputWidget.getSuffixIcon: usePassword != null is not true');
          usePassword!.value = !usePassword!.value;
          config.update((obj) => obj);
        },
      );
    }
    return super.getSuffixIcon();
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
              config.update((obj) {
                return obj..value = option.link;
              });
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
        config.update((obj) {
          return obj..value = color.toCssHex;
        });
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

/// 文件选择器控件
class FileSelectWidget extends TextareaWidget<InputConfig> {
  const FileSelectWidget({
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
      color: config.value.value.toColorFromCss,
      icon: const Icon(PhosphorIconsRegular.folderOpen),
      onPressed: selectFile,
    );
  }

  /// 选择文件
  void selectFile() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    config.update((obj) {
      return obj..value = FS.normalize(selectedDirectory);
    });
  }
}

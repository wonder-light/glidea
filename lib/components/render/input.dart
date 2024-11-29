import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/components/Common/Autocomplete.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/render.dart';

import 'base.dart';

class TextareaWidget<T extends TextareaConfig> extends ConfigBaseWidget<T> {
  const TextareaWidget({
    super.key,
    required super.config,
    super.isTop,
    super.ratio,
    super.labelPadding,
    super.contentPadding,
    this.onChanged,
  });

  /// 当用户选择一项时调用。
  final ValueChanged<String>? onChanged;

  bool get isTextarea => true;

  @override
  Widget buildContent(BuildContext context, ThemeData theme) {
    return TextFormField(
      initialValue: config.value,
      minLines: isTextarea ? 2 : null,
      maxLines: isTextarea ? 30 : 1,
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

class InputWidget extends ConfigBaseWidget<InputConfig> {
  const InputWidget({
    super.key,
    required super.config,
    super.isTop,
    super.ratio,
    super.labelPadding,
    super.contentPadding,
    this.onChanged,
  });

  /// 当用户选择一项时调用。
  final ValueChanged<String>? onChanged;

  @override
  Widget buildContent(BuildContext context, ThemeData theme) {
    /*ColorPicker(
      colorPickerWidth: 220,
      pickerColor: config.value.toColorFromCss,
      onColorChanged: (Color value) {
        onChanged?.call(value.toCssHex);
        //onSelected(value.toCssHex);
      },
      onHsvColorChanged: (HSVColor value) {
        onChanged?.call(value.toColor().toCssHex);
        onSelected(value.toColor().toCssHex);
      },
      pickerAreaHeightPercent: 0.7,
      enableAlpha: true,
      displayThumbColor: true,
      paletteType: PaletteType.hsvWithHue,
      labelTypes: [],
      portraitOnly: true,
    );*/
    return AutocompleteField<String>(
      optionsBuilder: (textEditingValue) => [config.value],
      optionsViewBuilder: (context, onSelected, options) {
        return SingleChildScrollView(
          child: Container(),
        );
      },
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 300,
      ),
    );
  }
}

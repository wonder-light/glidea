import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/components/Common/Autocomplete.dart';
import 'package:glidea/helpers/color.dart';
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
    return TypeAheadField(
      autoFlipDirection: true,
      itemBuilder: (BuildContext context, value) => Container(),
      onSelected: (Object? value) {},
      suggestionsCallback: (String search) => [config.value],
      constraints: const BoxConstraints(maxWidth: 200),
      offset: const Offset(-380, 0),
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'City',
            hoverColor: Colors.transparent,
          ),
        );
      },
      listBuilder: (context, children) => ColorPicker( // TODO: 需要更新 flex_color_picker 包
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
      ),
    );
    return AutocompleteField<String>(
      optionsBuilder: (textEditingValue) => [config.value],
      optionsViewBuilder: (context, onSelected, options) {
        return SingleChildScrollView(
          child: ColorPicker(
            width: 26,
            pickersEnabled: const {
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
              ColorPickerType.wheel: true,
            },
            enableShadesSelection: false,
            onColorChanged: (Color color) {},
            onColorChangeEnd: (Color color) {
              onChanged?.call(color.toCssHex);
              onSelected(color.toCssHex);
            },
          ),
        );
      },
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 300,
      ),
    );
  }
}

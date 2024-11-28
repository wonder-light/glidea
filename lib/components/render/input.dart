import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
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
  final ValueChanged<String?>? onChanged;

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

class InputWidget extends TextareaWidget<InputConfig> {
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
  bool get isTextarea => false;
}

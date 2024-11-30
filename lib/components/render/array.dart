import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

import 'base.dart';
import 'input.dart';
import 'picture.dart';
import 'radio.dart';
import 'select.dart';
import 'slider.dart';
import 'toggle.dart';

class ArrayWidget extends ConfigBaseWidget<ArrayConfig> {
  const ArrayWidget({
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
    return Obx(() {
      late List<Widget> childWidget;
      if (config.value.value.isEmpty) {
        childWidget = [
          Card(
            child: TextButton(
              onPressed: () {
                config.update(addItem);
              },
              child: const Icon(PhosphorIconsRegular.plus),
            ),
          ),
        ];
      } else {
        childWidget = [
          for (var item in config.value.value)
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var entity in config.value.arrayItems) createWidget(entity, item),
                ],
              ),
            ),
        ];
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: childWidget,
      );
    });
  }

  T addItem<T extends ArrayConfig>(T? obj, {int index = 0}) {
    if (obj == null) throw 'addItem: obj is null, But it is not allowed to be null';
    TJsonMap entity = {};
    for (var item in obj.arrayItems) {
      entity[item.name] = item.value;
    }
    obj.value.insert(index, entity);
    onChanged?.call(obj.value);
    return obj;
  }

  ConfigBaseWidget createWidget<T extends ConfigBase>(T entity, TJsonMap values) {
    // 复制对象
    final obj = entity.copy<T>()!..value = values[entity.name];
    // 标量值变化时需要重新覆盖原值
    void change(value) {
      values[obj.name] = value;
    }

    return switch (entity.type) {
      FieldType.input => InputWidget(isTop: false, config: (obj as InputConfig).obs, onChanged: change),
      FieldType.select => SelectWidget(isTop: false, config: (obj as SelectConfig).obs, onChanged: change),
      FieldType.textarea => TextareaWidget(isTop: false, config: (obj as TextareaConfig).obs, onChanged: change),
      FieldType.radio => RadioWidget(isTop: false, config: (obj as RadioConfig).obs, onChanged: change),
      FieldType.toggle => ToggleWidget(isTop: false, config: (obj as ToggleConfig).obs, onChanged: change),
      FieldType.slider => SliderWidget(isTop: false, config: (obj as SliderConfig).obs, onChanged: change),
      FieldType.picture => PictureWidget(isTop: false, config: (obj as PictureConfig).obs, onChanged: change),
      FieldType.array => ArrayWidget(isTop: false, config: (obj as ArrayConfig).obs),
    };
  }
}

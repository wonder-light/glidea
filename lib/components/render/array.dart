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

  /// 在指定位置添加一系列字段的值
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

  /// 创建对应类型的子控件
  ConfigBaseWidget createWidget<T extends ConfigBase>(T entity, TJsonMap values) {
    // 复制对象
    final obj = entity.copy<T>()!..value = values[entity.name];
    // 标量值变化时需要重新覆盖原值
    void change(value) {
      values[obj.name] = value;
    }

    if (entity.type == FieldType.array) {
      return ArrayWidget.create(config: obj);
    }
    return ArrayWidget.create(config: obj, onChanged: change);
  }

  /// 创建对应类型的子控件
  static ConfigBaseWidget create<T extends ConfigBase>({required T config, bool isTop = true, ValueChanged<dynamic>? onChanged}) {
    return switch (config.type) {
      FieldType.input => InputWidget(config: (config as InputConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.select => SelectWidget(config: (config as SelectConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.textarea => TextareaWidget(config: (config as TextareaConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.radio => RadioWidget(config: (config as RadioConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.toggle => ToggleWidget(config: (config as ToggleConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.slider => SliderWidget(config: (config as SliderConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.picture => PictureWidget(config: (config as PictureConfig).obs, isTop: isTop, onChanged: onChanged),
      FieldType.array => ArrayWidget(config: (config as ArrayConfig).obs, isTop: isTop, onChanged: onChanged),
    };
  }
}

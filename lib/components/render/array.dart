import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, RxBool;
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

/// 渲染 [ArrayConfig] 的控件
class ArrayWidget extends ConfigBaseWidget<ArrayConfig> {
  const ArrayWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConfigLayoutWidget(
      isVertical: isVertical,
      config: config.value,
      child: Obx(() {
        late List<Widget> childWidget;
        var items = config.value.value;
        if (items.isEmpty) {
          childWidget = [
            Card(
              child: TextButton(
                onPressed: () => config.update(addItem),
                child: const Icon(PhosphorIconsRegular.plus),
              ),
            ),
          ];
        } else {
          childWidget = [
            for (var i = 0, length = items.length; i < length; i++)
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var entity in config.value.arrayItems) createWidget(entity, items[i]),
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
      }),
    );
  }

  /// 在指定位置添加一系列字段的值
  T addItem<T extends ArrayConfig>(T obj, {int index = 0}) {
    TJsonMap entity = {};
    for (var item in obj.arrayItems) {
      entity[item.name] = item.value;
    }
    obj.value.insert(index, entity);
    onChanged?.call(obj.value);
    return obj;
  }

  /// 创建对应类型的子控件
  Widget createWidget<T extends ConfigBase>(T entity, TJsonMap values) {
    // 复制对象
    assert(entity.copy<T>() != null, 'ArrayWidget: create widget failed');
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
  static Widget create<T extends ConfigBase>({
    required T config,
    bool isVertical = true,
    ValueChanged<dynamic>? onChanged,
    RxBool? usePassword,
    int scope = -1,
  }) {
    return switch (config.type) {
      FieldType.input => InputWidget(config: (config as InputConfig).obs, isVertical: isVertical, onChanged: onChanged, usePassword: usePassword),
      FieldType.select => SelectWidget(config: (config as SelectConfig).obs, isVertical: isVertical, onChanged: onChanged),
      FieldType.textarea => TextareaWidget(config: (config as TextareaConfig).obs, isVertical: isVertical, onChanged: onChanged),
      FieldType.radio => RadioWidget(config: (config as RadioConfig).obs, isVertical: isVertical, onChanged: onChanged),
      FieldType.toggle => ToggleWidget(config: (config as ToggleConfig).obs, isVertical: isVertical, onChanged: onChanged),
      FieldType.slider => SliderWidget(config: (config as SliderConfig).obs, isVertical: isVertical, onChanged: onChanged),
      FieldType.picture => PictureWidget(config: (config as PictureConfig).obs, isVertical: isVertical, onChanged: onChanged, scope: scope),
      FieldType.array => ArrayWidget(config: (config as ArrayConfig).obs, isVertical: isVertical, onChanged: onChanged),
    };
  }
}

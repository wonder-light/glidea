part of 'base.dart';

/// 渲染 [ArrayConfig] 的控件
class ArrayWidget extends ConfigBaseWidget<ArrayConfig> {
  const ArrayWidget({
    super.key,
    required super.config,
    super.isVertical,
    super.onChanged,
  });

  @override
  Widget buildContent(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 0.6,
      ),
    );
    return Obx(() {
      var items = config.value.value;
      return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          if (index >= items.length) {
            return _buildAddCard(decoration);
          }
          return Container(
            decoration: decoration,
            padding: kAllPadding16,
            child: Column(
              spacing: kTopPadding8.top,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var entity in config.value.arrayItems) createWidget(entity, items[index]),
                _buildActions(colorScheme, index),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Padding(padding: kTopPadding16),
        itemCount: items.length + 1,
      );
    });
  }

  /// 卡片上的操作按钮
  Widget _buildActions(ColorScheme colorScheme, int index) {
    return Row(
      spacing: kTopPadding8.top,
      children: [
        IconButton(
          onPressed: () => config.update((obj) => addItem(obj, index: index)),
          icon: Icon(PhosphorIconsRegular.plus, color: colorScheme.primary),
        ),
        IconButton(
          onPressed: () => config.update((obj) => deleteItem(obj, index: index)),
          icon: Icon(PhosphorIconsRegular.minus, color: colorScheme.primary),
        )
      ],
    );
  }

  /// 构建添加按钮的卡片
  Widget _buildAddCard([Decoration? decoration]) {
    return Container(
      decoration: decoration,
      child: TextButton(
        onPressed: () => config.update(addItem),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
    );
  }

  /// 在指定位置添加一系列字段的值
  T addItem<T extends ArrayConfig>(T obj, {int index = -1}) {
    TJsonMap entity = {};
    for (var item in obj.arrayItems) {
      entity[item.name] = item.value;
    }
    if (index < 0) {
      // 添加到末尾
      obj.value.add(entity);
    } else {
      // 在 index 处插入
      obj.value.insert(index, entity);
    }
    onChanged?.call(obj.value);
    return obj;
  }

  /// 删除指定位置的字段, 如果 [index] = -1, 则删除最后的字段
  T deleteItem<T extends ArrayConfig>(T obj, {int index = -1}) {
    if (index < 0) {
      obj.value.removeLast();
    } else {
      obj.value.removeAt(index);
    }
    return obj;
  }

  /// 创建对应类型的子控件
  Widget createWidget<T extends ConfigBase>(T entity, TJsonMap values) {
    // 复制对象
    assert(entity.copy<T>() != null, 'ArrayWidget: create widget failed');
    final obj = entity.copy<T>()!;
    obj.value = values[entity.name] ??= obj.value;
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

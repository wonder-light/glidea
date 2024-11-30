import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty, Json;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/interfaces/types.dart';

/// 基础配置的公共部分
@jsonSerializable
@Json(discriminatorProperty: 'type')
abstract class ConfigBase<T> {
  ConfigBase({
    this.name = '',
    this.label = '',
    this.group = '',
    this.note = '',
  });

  /// 变量名称
  @JsonProperty()
  String name;

  /// 显示的字段名称
  @JsonProperty()
  String label;

  /// 字段的分组
  @JsonProperty()
  String group;

  /// 字段的输入类型
  ///
  ///     input, select, textarea, radio, toggle, picture-upload, markdown（可提供一个 markdown 的输入框）, array
  @JsonProperty()
  FieldType get type => FieldType.input;

  /// 辅助文本, 展示在表单空间下面
  @JsonProperty()
  String note;

  /// 字段默认值
  @JsonProperty()
  T get value;

  @JsonProperty()
  set value(T newValue);
}

/// 字符串值配置
@jsonSerializable
abstract class ConfigString extends ConfigBase<String> {
  ConfigString({
    super.name,
    super.label,
    super.group,
    super.note,
    this.value = '',
  });

  @override
  @JsonProperty()
  String value;
}

/// 布尔值配置
@jsonSerializable
abstract class ConfigBool extends ConfigBase<bool> {
  ConfigBool({
    super.name,
    super.label,
    super.group,
    super.note,
    this.value = false,
  });

  @override
  @JsonProperty()
  bool value;
}

/// 整数值配置
@jsonSerializable
abstract class ConfigInt extends ConfigBase<int> {
  ConfigInt({
    super.name,
    super.label,
    super.group,
    super.note,
    this.value = 0,
  });

  @override
  @JsonProperty()
  int value;
}

/// 数组映射值配置
@jsonSerializable
abstract class ConfigArrayMap extends ConfigBase<List<TJsonMap>> {
  ConfigArrayMap({
    super.name,
    super.label,
    super.group,
    super.note,
    this.value = const [],
  });

  /// 列表中的每一项数据都是对字段的值的记录
  @override
  @JsonProperty()
  List<TJsonMap> value;
}

/// 富文本字段配置
@jsonSerializable
@Json(discriminatorValue: FieldType.textarea)
class TextareaConfig extends ConfigString {
  TextareaConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    this.hint = '',
  });

  /// 输入框中的提示文本
  ///
  /// [type] 为 'input'，'textarea' 时可用
  @JsonProperty()
  String hint;

  @override
  @JsonProperty()
  FieldType get type => FieldType.textarea;
}

/// 输入字段配置
@jsonSerializable
@Json(discriminatorValue: FieldType.input)
class InputConfig extends TextareaConfig {
  InputConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    super.hint,
    this.card = InputCardType.none,
  });

  /// card 配置
  ///
  /// 可选值：
  ///
  ///     color:  提供一个推荐颜色卡片快捷选择
  ///     post:   提供文章数据卡片提供选择
  ///     none:   不显示卡片
  @JsonProperty()
  InputCardType card;

  @override
  @JsonProperty()
  FieldType get type => FieldType.input;
}

/// 下拉列表配置
@jsonSerializable
@Json(discriminatorValue: FieldType.select)
class SelectConfig extends ConfigString {
  SelectConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    this.options = const [],
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.select;

  /// 选项列表
  @JsonProperty()
  List<SelectOption> options;
}

/// 单选按钮组配置
@jsonSerializable
@Json(discriminatorValue: FieldType.radio)
class RadioConfig extends SelectConfig {
  RadioConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    super.options,
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.radio;
}

/// 开关按钮配置
@jsonSerializable
@Json(discriminatorValue: FieldType.toggle)
class ToggleConfig extends ConfigBool {
  ToggleConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.toggle;
}

/// 图片上传配置
@jsonSerializable
@Json(discriminatorValue: FieldType.picture)
class PictureConfig extends ConfigString {
  PictureConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.picture;
}

/// 数组项配置
@jsonSerializable
@Json(discriminatorValue: FieldType.array)
class ArrayConfig extends ConfigArrayMap {
  ArrayConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    this.arrayItems = const [],
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.array;

  /// 数组中的每一项数据记录的都是字段的定义
  @JsonProperty()
  List<ConfigBase> arrayItems;
}

/// 滑块配置, 范围是 (0, ∞)
@jsonSerializable
@Json(discriminatorValue: FieldType.slider)
class SliderConfig extends ConfigInt {
  SliderConfig({
    super.name,
    super.label,
    super.group,
    super.note,
    super.value,
    this.max = 100,
  });

  @override
  @JsonProperty()
  FieldType get type => FieldType.slider;

  /// 滑动范围最大值, 必须大于 0
  @JsonProperty()
  int max;
}

/// 下拉列表中的选项
@jsonSerializable
class SelectOption {
  /// 创建列表中的选项
  SelectOption({this.label = '', this.value = ''});

  /// 创建列表中的选项
  ///
  /// 名称和变量名都一致
  SelectOption.all(String data) : this(label: data, value: data);

  /// 选项显示名称
  @JsonProperty()
  String label;

  /// 选项对应值
  @JsonProperty()
  String value;
}

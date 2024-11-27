import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty, Json;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/interfaces/types.dart';

/// 基础配置的公共部分
@jsonSerializable
@Json(discriminatorProperty: 'type')
abstract class ConfigBase<T> {
  /// 变量名称
  @JsonProperty()
  String name = '';

  /// 显示的字段名称
  @JsonProperty()
  String label = '';

  /// 字段的分组
  @JsonProperty()
  String group = '';

  /// 字段的输入类型
  ///
  ///     input, select, textarea, radio, toggle, picture-upload, markdown（可提供一个 markdown 的输入框）, array
  @JsonProperty()
  FieldType get type => FieldType.input;

  /// 辅助文本, 展示在表单空间下面
  @JsonProperty()
  String note = '';

  /// 字段默认值
  @JsonProperty()
  T get value;

  @JsonProperty()
  set value(T newValue);
}

/// 字符串值配置
@jsonSerializable
abstract class ConfigString extends ConfigBase<String> {
  @override
  @JsonProperty()
  String value = '';
}

/// 布尔值配置
@jsonSerializable
abstract class ConfigBool extends ConfigBase<bool> {
  @override
  @JsonProperty()
  bool value = false;
}

/// 整数值配置
@jsonSerializable
abstract class ConfigInt extends ConfigBase<int> {
  @override
  @JsonProperty()
  int value = 0;
}

/// 数组映射值配置
@jsonSerializable
abstract class ConfigArrayMap extends ConfigBase<List<TJsonMap>> {
  @override
  @JsonProperty()
  List<TJsonMap> value = [];
}

/// 富文本字段配置
@jsonSerializable
@Json(discriminatorValue: FieldType.textarea)
class TextareaConfig extends ConfigString {
  /// 输入框中的提示文本
  ///
  /// [type] 为 'input'，'textarea' 时可用
  @JsonProperty()
  String hint = '';

  @override
  @JsonProperty()
  FieldType get type => FieldType.textarea;
}

/// 输入字段配置
@jsonSerializable
@Json(discriminatorValue: FieldType.input)
class InputConfig extends TextareaConfig {
  /// card 配置
  ///
  /// 可选值：
  ///
  ///     color:  提供一个推荐颜色卡片快捷选择
  ///     post:   提供文章数据卡片提供选择
  ///     none:   不显示卡片
  @JsonProperty()
  InputCardType card = InputCardType.none;

  @override
  @JsonProperty()
  FieldType get type => FieldType.input;
}

/// 下拉列表配置
@jsonSerializable
@Json(discriminatorValue: FieldType.select)
class SelectConfig extends ConfigString {
  @override
  @JsonProperty()
  FieldType get type => FieldType.select;

  /// 选项列表
  @JsonProperty()
  List<SelectOption> options = [];
}

/// 单选按钮组配置
@jsonSerializable
@Json(discriminatorValue: FieldType.radio)
class RadioConfig extends SelectConfig {
  @override
  @JsonProperty()
  FieldType get type => FieldType.radio;
}

/// 开关按钮配置
@jsonSerializable
@Json(discriminatorValue: FieldType.toggle)
class ToggleConfig extends ConfigBool {
  @override
  @JsonProperty()
  FieldType get type => FieldType.toggle;
}

/// 图片上传配置
@jsonSerializable
@Json(discriminatorValue: FieldType.picture)
class PictureConfig extends ConfigString {
  @override
  @JsonProperty()
  FieldType get type => FieldType.picture;
}

/// 数组项配置
@jsonSerializable
@Json(discriminatorValue: FieldType.array)
class ArrayConfig extends ConfigArrayMap {
  @override
  @JsonProperty()
  FieldType get type => FieldType.array;

  /// 数组中每一项数据对象的字段定义
  @JsonProperty()
  List<ConfigBase> arrayItems = [];
}

/// 滑块配置, 范围是 (0, ∞)
@jsonSerializable
@Json(discriminatorValue: FieldType.slider)
class SliderConfig extends ConfigInt {
  @override
  @JsonProperty()
  FieldType get type => FieldType.slider;

  /// 滑动范围最大值, 必须大于 0
  @JsonProperty()
  int max = 100;
}

/// 下拉列表中的选项
@jsonSerializable
class SelectOption {
  /// 选项显示名称
  @JsonProperty()
  String label = '';

  /// 选项对应值
  @JsonProperty()
  String value = '';
}

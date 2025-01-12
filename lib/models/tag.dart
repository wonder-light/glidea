import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/helpers/uid.dart';

/// 标签
@jsonSerializable
class Tag {
  /// 标签名
  @JsonProperty()
  String name = '';

  /// 标签是否使用
  @JsonProperty()
  bool used = false;

  /// 简链
  @JsonProperty()
  String slug = Uid.shortId;

  /// 标签索引
  @JsonProperty()
  int? index;
}

/// 标签渲染数据
@jsonSerializable
class TagRender extends Tag {
  /// 标签链接
  @JsonProperty()
  String link = '';

  /// 标签数量
  @JsonProperty()
  int count = 0;
}

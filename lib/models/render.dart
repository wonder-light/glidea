import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;

/// 分页进度
@jsonSerializable
class Pagination {
  /// 上一页 URL
  @JsonProperty()
  String prev = '';

  /// 下一页 URL
  @JsonProperty()
  String next = '';
}

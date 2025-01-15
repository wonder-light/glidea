import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;

/// 分页进度
@jsonSerializable
class Pagination {
  /// 基础 URL
  @JsonProperty()
  String base = '';

  /// 上一页 URL
  @JsonProperty()
  String prev = '';

  /// 下一页 URL
  @JsonProperty()
  String next = '';

  /// 总页数
  @JsonProperty()
  int total = 0;

  /// 当前页数
  @JsonProperty()
  int current = 0;

  /// 创建此对象的副本，但将给定字段替换为新值
  Pagination copyWith({String? base, String? prev, String? next, int? total, int? current}) {
    return Pagination()
      ..base = base ?? this.base
      ..prev = prev ?? this.prev
      ..next = next ?? this.next
      ..total = total ?? this.total
      ..current = current ?? this.current;
  }
}

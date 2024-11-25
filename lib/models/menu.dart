import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/enum/enums.dart';

@jsonSerializable
class Menu {
  /// 菜单名
  @JsonProperty()
  String name = '';

  /// 内链后或者外链类型
  @JsonProperty()
  MenuTypes openType = MenuTypes.internal;

  /// 链接
  @JsonProperty()
  String link = '';

  /// 菜单索引
  @JsonProperty()
  int? index;
}

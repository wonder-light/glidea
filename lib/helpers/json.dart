import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';

/// 对象上的 json 扩展
extension JsonObjectExtend on Object {
  /// object 对象序列化为 json 字符串
  String toJson([SerializationOptions? options]) => JsonMapper.toJson(this, options);

  /// object 对象序列化为 Map 对象
  Map<String, dynamic>? toMap([SerializationOptions? options]) => JsonMapper.toMap(this, options);

  /// 用于复制类型 T 的 Dart 对象的 clone 方法的别名
  T? copy<T>() => JsonMapper.copy<T>(this as T);

  /// 复制 T 类型的 Dart 对象并将其与 other 合并
  T? copyWith<T>(Map<String, dynamic> other) => JsonMapper.copyWith<T>(this as T, other);

  T? copyWithObj<T, S>(S other) => JsonMapper.copyWith<T>(this as T, JsonMapper.toMap(other)!);

  /// 将 JSON [String] 或 [Object] 或 [Map<String, dynamic>] 类型转换为 T 类型的 Dart 对象实例
  T? deserialize<T>([DeserializationOptions? options]) => JsonMapper.deserialize(this, options);
}

/// json 字符串扩展
extension JsonStringExtend on String {
  /// 将 json 字符串转换为类型为 T 的 Dart 对象
  T? fromJson<T>([DeserializationOptions? options]) => JsonMapper.fromJson<T>(this, options);
}

extension MapExtend on Map<String, dynamic> {
  /// 将 [Map<String, dynamic> ] 转换为类型 T 的 Dart 对象实例
  T? fromMap<T>([DeserializationOptions? options]) => JsonMapper.fromMap<T>(this, options);

  /// 递归深度合并两个映射
  Map<String, dynamic> mergeMaps(Map<String, dynamic> map) => JsonMapper.mergeMaps(this, map);
}

/// Json 序列化帮助类
class JsonHelp {
  /// JsonMapper 在项目中的初始化
  static void initialized() {
    JsonMapper().useAdapter(
      JsonMapperAdapter(
        valueDecorators: {
          typeOf<List<Post>>(): (value) => value.cast<Post>(),
          typeOf<List<Tag>>(): (value) => value.cast<Tag>(),
          typeOf<List<Menu>>(): (value) => value.cast<Menu>(),
          typeOf<List<PostRender>>(): (value) => value.cast<PostRender>(),
          typeOf<List<TagRender>>(): (value) => value.cast<TagRender>()
        },
        converters: {},
        enumValues: {
          DeployPlatform: DeployPlatform.values,
          ProxyWay: ProxyWay.values,
          MenuTypes: MenuTypes.values,
          UrlFormats: UrlFormats.values,
        },
      ),
    );
  }
}

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/crypto.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/main.reflectable.dart' show initializeReflectable;
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/tag.dart';

/// 对象上的 json 扩展
extension JsonObjectExtend on Object {
  /// object 对象序列化为 json 字符串
  String toJson([SerializationOptions? options]) => JsonMapper.toJson(this, options);

  /// object 对象序列化为 Map 对象
  Map<String, dynamic>? toMap([SerializationOptions? options]) => JsonMapper.toMap(this, options);

  /// 用于复制类型 T 的 Dart 对象的 clone 方法的别名
  T? copy<T>() => JsonMapper.copy<T>(this as T);

  /// 复制 T 类型的 Dart 对象并将其与 other 合并, 然后反序列化到指定类型的对象
  T? copyWith<T>(Map<String, dynamic> other) => JsonMapper.fromMap<T>(toMap()?.mergeMaps(other));

  /// 将 JSON [String] 或 [Object] 或 [Map<String, dynamic>] 类型转换为 T 类型的 Dart 对象实例
  T? deserialize<T>([DeserializationOptions? options]) => JsonMapper.deserialize<T>(this, options);
}

/// json 字符串扩展
extension JsonStringExtend on String {
  /// 将 json 字符串转换为类型为 T 的 Dart 对象
  T? fromJson<T>([DeserializationOptions? options]) => JsonMapper.fromJson<T>(this, options);

  /// 获取加密哈希值
  Future<String> getHash() => Crypto.cryptoStr(this);

  /// 分割字符串同时包含分隔符
  List<String> splitWithSep(Pattern pattern) => pattern.allMatchesWithSep(this);

  /// 分割字符串同时包含分隔符, 并对其进行自定义映射
  List<T> splitMapWithSep<T>({
    required Pattern pattern,
    required TChangeCallback<T, Match> onMatch,
    required TChangeCallback<T, String> onNonMatch,
  }) {
    return pattern.allMatchesMapWithSep(input: this, onMatch: onMatch, onNonMatch: onNonMatch);
  }
}

extension MapExtend on Map<String, dynamic> {
  /// 将 [Map<String, dynamic> ] 转换为类型 T 的 Dart 对象实例
  T? fromMap<T>([DeserializationOptions? options]) => JsonMapper.fromMap<T>(this, options);

  /// 递归深度合并两个映射
  Map<String, dynamic> mergeMaps(Map<String, dynamic> map) => JsonMapper.mergeMaps(Map.from(this), map);
}

extension RegExpExtension on Pattern {
  /// 分割字符串同时包含分隔符
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    return allMatchesMapWithSep(
      input: input,
      onMatch: _onMatch,
      onNonMatch: _onNonMatch,
    );
  }

  /// 分割字符串同时包含分隔符, 并对其进行自定义映射
  List<T> allMatchesMapWithSep<T>({
    required String input,
    required TChangeCallback<T, Match> onMatch,
    required TChangeCallback<T, String> onNonMatch,
    int start = 0,
  }) {
    // 结果
    var result = <T>[];
    var str = '';
    // 循环匹配
    for (var match in allMatches(input, start)) {
      assert(match[0] != null, 'in allMatchesWithSep, match[0] == null');
      // 添加非匹配字符串
      str = input.substring(start, match.start);
      if(str.isNotEmpty) result.add(onNonMatch(str));
      // 添加匹配字符串
      if(match.groupCount > 0) result.add(onMatch(match));
      // 设置下一次的起始位置
      start = match.end;
    }
    // 添加末尾的未匹配字符串
    str = input.substring(start);
    if(str.isNotEmpty) result.add(onNonMatch(str));
    // 返回
    return result;
  }

  static String _onMatch(Match match) => match[0]!;

  static String _onNonMatch(String value) => value;
}

/// Json 序列化帮助类
class JsonHelp {
  /// JsonMapper 在项目中的初始化
  static void initialized() {
    initializeReflectable();
    initAdapter();
  }

  /// 初始适配器
  static void initAdapter() {
    // 初始适配器
    JsonMapper().useAdapter(
      JsonMapperAdapter(
        valueDecorators: {
          typeOf<List<Post>>(): (value) => value.cast<Post>(),
          typeOf<List<Tag>>(): (value) => value.cast<Tag>(),
          typeOf<List<Menu>>(): (value) => value.cast<Menu>(),
          typeOf<List<PostRender>>(): (value) => value.cast<PostRender>(),
          typeOf<List<TagRender>>(): (value) => value.cast<TagRender>(),
          typeOf<List<ConfigBase>>(): (value) => value.cast<ConfigBase>(),
          typeOf<List<SelectOption>>(): (value) => value.cast<SelectOption>(),
          typeOf<List<TJsonMap>>(): (value) => value.cast<TJsonMap>(),
          typeOf<Map<String, dynamic>>(): (value) => Map<String, dynamic>.from(value),
        },
        converters: {
          FieldType: FieldTypeConverter(),
          InputCardType: InputCardConverter(),
        },
        enumValues: {
          DeployPlatform: DeployPlatform.values,
          CommentPlatform: CommentPlatform.values,
          ProxyWay: ProxyWay.values,
          MenuTypes: MenuTypes.values,
          UrlFormats: UrlFormats.values,
          FieldType: FieldType.values,
          InputCardType: InputCardType.values,
        },
      ),
    );
  }
}

/// FieldType 枚举转换
class FieldTypeConverter extends EnumConverterShort {
  @override
  Object? fromJSON(jsonValue, DeserializationContext context) {
    // 从 field-type => fieldType
    // transformIdentifierCaseStyle(jsonValue, CaseStyle.camel, CaseStyle.kebab)
    jsonValue = switch (jsonValue) {
      'switch' => 'toggle',
      'picture-upload' => 'picture',
      _ => jsonValue,
    };
    // context.transformIdentifier(value)
    return super.fromJSON(jsonValue, context);
  }
}

/// InputCard 枚举转换
class InputCardConverter extends EnumConverterShort {
  @override
  Object? fromJSON(jsonValue, DeserializationContext context) {
    return super.fromJSON(jsonValue, context) ?? InputCardType.none;
  }
}

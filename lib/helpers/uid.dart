import 'package:uuid/uuid.dart';

/// 创建 Uuid 类的新实例
class Uid {
  /// Uuid 类的新实例
  static const uid = Uuid();

  /// 生成基于时间的版本1 UUID
  static String get v1 => Uid.uid.v1();

  /// 生成RNG版本4 UUID
  static String get v4 => Uid.uid.v4();

  /// 生成一个基于名称空间和名称的版本5 UUID
  static String get v5 => Uid.uid.v5(Namespace.dns.value, Namespace.oid.value);

  /// 生成一个基于时间的草案版本6 UUID
  static String get v6 => Uid.uid.v6();

  /// 生成一个草案基于时间的版本7 UUID 作为一个 UuidValue 对象
  static String get v7 => Uid.uid.v7();

  /// 生成基于时间的版本8 UUID 草案
  static String get v8 => Uid.uid.v8();

  /// 生成短 uid
  static String get shortId => v4.substring(0, 13).toUpperCase();
}

import 'package:get/get.dart' show Trans;

/// 错误
class Mistake extends Error implements Exception {
  /// 创建 Mistake 异常类
  ///
  /// [message] 错误消息
  ///
  /// [hint] 本地化语言提示
  Mistake({
    this.message,
    String? hint,
  }) : hint = hint?.tr ?? '';

  /// 错误消息
  final String? message;

  /// 本地化语言提示
  final String hint;

  @override
  String toString() => message ?? 'failed';
}

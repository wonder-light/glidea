import 'package:get/get.dart' show Trans;

/// 错误
class Mistake extends Error implements Exception {
  /// 创建 Mistake 异常类
  ///
  /// [message] 错误消息
  ///
  /// [hint] 本地化语言提示
  Mistake({
    this.message = '',
    String? hint,
  }) : hint = hint?.tr ?? '';

  /// 创建 Mistake 异常类, 并将其与 [error] 的内容进行合并, 需要满足 [error] 是 [Mistake] 的实例
  ///
  /// 如果 [error.message] 是空的, 则使用 [message], 否则通过 [\n] 将 [message] 和 [error.message] 进行组合
  ///
  /// [hint] 不为空, 则不使用 [error.hint], 否则使用 [error.hint]
  Mistake.add({
    String? message,
    String? hint,
    dynamic error,
  })  : message = '$message\n$error',
        hint = (hint ?? (error is Mistake ? error.hint : '')).tr;

  /// 错误消息
  final String message;

  /// 本地化语言提示
  final String hint;

  /// 添加 [message] 消息
  Mistake addMessage(String? message) {
    return Mistake.add(
      message: this.message,
      hint: hint,
      error: message,
    );
  }

  @override
  String toString() => 'message: $message\nhint: ${hint.tr}';
}

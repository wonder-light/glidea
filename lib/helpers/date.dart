import 'package:intl/intl.dart' show DateFormat;

extension DateTimeExt on DateTime {
  /// 将 [DateTime] 格式化为字符串
  String format({String? pattern}) {
    if (pattern == null || pattern.trim().isEmpty) {
      toIso8601String();
    }
    // YYYY-MM-DD HH:mm:ss => yyyy-MM-dd hh:mm:ss
    pattern = pattern!.replaceAllMapped(RegExp(r'[YDH]'), (str) {
      return switch (str[0]) {
        'Y' => 'y',
        'D' => 'd',
        'H' => 'h',
        _ => str[0] ?? '',
      };
    });
    return DateFormat(pattern).format(this);
  }

  /// 将 [DateTime] 设置为对应的格式化
  DateTime setFormat({String? pattern}) {
    if (pattern?.trim().isEmpty ?? true) return this;
    // 格式
    final format = DateFormat(pattern);
    try {
      // 转换
      return format.parse(format.format(this));
    } catch (e) {
      return this;
    }
  }
}

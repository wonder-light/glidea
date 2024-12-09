import 'package:intl/intl.dart' show DateFormat;

extension DateTimeExt on DateTime {
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
}

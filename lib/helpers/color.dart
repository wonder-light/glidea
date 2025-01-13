import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// 返回颜色的大写 RGB 十六进制字符串，包括 alpha 通道
  ///
  ///     'FFF44336'
  ///     'FFD793D1'
  String get toHexAlpha {
    final value = _floatToInt8(a) << 24 | _floatToInt8(r) << 16 | _floatToInt8(g) << 8 | _floatToInt8(b) << 0;
    return value.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  /// 返回颜色的大写 RGB 十六进制字符串，不包括 alpha 通道
  ///
  ///     '0xF44336'
  ///     '0xD793D1'
  String get toHex {
    return toHexAlpha.substring(2);
  }

  /// 返回 CSS 样式的颜色的大写 RGB 十六进制字符串，包括 alpha 通道
  String get toCssHex {
    String hexColor = toHexAlpha;
    // 将后两位放到前两位
    // Dart Color => Css Color
    // 'FFF44336' => 'F44336FF'
    return hexColor.substring(2) + hexColor.substring(0, 2);
  }
}

extension NullStringExtensions on String? {
  /// 将字符串解析为十六进制值编码 (A)RGB 字符串
  Color? _tryParse({bool css = false}) {
    // 如果 String为 null, 则返回 null, 无法解析
    // 如果字符串长度为大于 50, 作为安全预防措施，我们不会尝试将其解析为颜色
    if (this == null || this!.length > 50) return null;
    // 删除所有空格、#、0x，我们允许它们，但忽略它们
    String hexColor = this!.replaceAll(RegExp(r'([\s#])|(0x)'), '');
    // 如果 String 的长度为零，则返回透明，无法解析
    if (hexColor == '') return null;
    // 如果字符串短于 6，则在其左侧填充 0
    hexColor = hexColor.padLeft(6, '0');
    // 如果字符串短于 8，则在其左侧填充 F
    hexColor = hexColor.padLeft(8, 'F');
    // 我们只尝试解析剩余字符串中的最后 8 个字符，其余的仍然可以是任何字符
    hexColor = hexColor.substring(hexColor.length - 8);
    if (css) {
      // 将后两位放到前两位
      // CSS Color  => Dart Color
      // 'F44336FF' => 'FFF44336'
      hexColor = hexColor.substring(6) + hexColor.substring(0, 6);
    }
    hexColor = '0x$hexColor';
    // 我们只尝试解析剩余字符串中的最后 8 个字符，其余的仍然可以是任何字符
    final int? intColor = int.tryParse(hexColor);
    return intColor != null ? Color(intColor) : null;
  }

  /// 将 (A)RGB 字符串转换为 Dart Color
  ///
  /// 如果结果字符串不能被解析为颜色，为空或 null，则返回完全不透明的黑色，否则返回颜色
  /// 当存在无法解析为颜色值的字符串时，它返回 null
  /// 然后，您可以决定如何处理错误，而不仅仅是接收到完全不透明的黑色
  Color? get tryToColor => _tryParse();

  /// 将 CSS (A)RGB 字符串转换为 Dart Color
  ///
  /// 如果结果字符串不能被解析为颜色，为空或 null，则返回完全不透明的黑色，否则返回颜色
  /// 当存在无法解析为颜色值的字符串时，它返回null
  /// 然后，您可以决定如何处理错误，而不仅仅是接收到完全不透明的黑色
  Color? get tryToColorFromCss => _tryParse(css: true);
}

extension StringExtensions on String {
  /// 将 (A)RGB 字符串转换为 Dart Color
  Color get toHexColor => tryToColor ?? Colors.black;

  /// 将 CSS (A)RGB 字符串转换为 Dart Color
  Color get toColorFromCss => tryToColorFromCss ?? Colors.black;
}

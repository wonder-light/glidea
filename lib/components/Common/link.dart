import 'package:flutter/material.dart';
import 'package:glidea/helpers/log.dart';
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

/// 链接组件
class LinkWidget extends StatelessWidget {
  const LinkWidget({
    super.key,
    required this.url,
    required this.text,
    this.style,
  });

  /// 链接内容
  final String url;

  /// 链接内容
  final String text;

  /// 链接样式
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    var textStyle = style;
    if (textStyle == null) {
      final theme = Theme.of(context);
      textStyle = theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.primary,
      );
    }
    return GestureDetector(
      onTap: openUrl,
      child: MouseRegion(
        cursor: WidgetStateMouseCursor.clickable,
        child: Text(text, style: textStyle),
      ),
    );
  }

  /// 打开 URL
  void openUrl() async {
    if (!await launchUrlString(url)) {
      Log.w('github 打开失败');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/lang/base.dart';
import 'package:re_editor/re_editor.dart' show CodeEditor, CodeEditorStyle, CodeHighlightTheme, CodeHighlightThemeMode;
import 'package:re_editor/re_editor.dart' show CodeLineEditingController, CodeLineEditingValue;
import 'package:re_highlight/languages/latex.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/base16/atelier-forest-light.dart';

final _langMarkdown = Mode(
  refs: {
    ...?langLatex.refs,
    ...?langXml.refs,
    ...?langMarkdown.refs,
  },
  name: langMarkdown.name,
  aliases: langMarkdown.aliases,
  contains: [
    ...?langMarkdown.contains,
    ...?langXml.contains,
    ...?langLatex.contains,
  ],
  caseInsensitive: true,
  unicodeRegex: true,
);

class PostContent extends StatelessWidget {
  const PostContent({super.key, required this.controller, this.onChanged, this.factor});

  /// 给予子元素的传入宽度的分数
  final double? factor;

  /// 编辑器字段的控制器
  final CodeLineEditingController controller;

  /// 当用户发起对编辑器的值被更改，例如插入或删除
  final ValueChanged<CodeLineEditingValue>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(Get.context!);
    final style = theme.textTheme.bodyMedium?.apply(fontSizeFactor: 1.1);
    return CodeEditor(
      autofocus: false,
      scrollbarBuilder: buildScrollbar,
      controller: controller,
      padding: kTopPadding16.flipped,
      hint: Tran.startWriting.tr,
      onChanged: onChanged,
      style: CodeEditorStyle(
        fontSize: style?.fontSize,
        fontFamily: style?.fontFamily,
        hintTextColor: theme.colorScheme.outlineVariant,
        codeTheme: CodeHighlightTheme(
          languages: {
            'mkdown': CodeHighlightThemeMode(mode: _langMarkdown),
          },
          theme: atelierForestLightTheme,
        ),
      ),
    );
  }

  /// 构建滚动条
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(controller: details.controller, child: child);
  }
}

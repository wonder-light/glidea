import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, RxBool, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/post/context_menu.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:re_editor/re_editor.dart' show CodeEditor, CodeEditorStyle, CodeHighlightTheme, CodeHighlightThemeMode;
import 'package:re_editor/re_editor.dart' show CodeLineEditingController, CodeFindController, CodeLineEditingValue;
import 'package:re_highlight/languages/latex.dart' show langLatex;
import 'package:re_highlight/languages/markdown.dart' show langMarkdown;
import 'package:re_highlight/languages/xml.dart' show langXml;
import 'package:re_highlight/re_highlight.dart' show Mode;
import 'package:re_highlight/styles/base16/atelier-forest-light.dart' show atelierForestLightTheme;

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

class PostContent extends StatefulWidget {
  const PostContent({super.key, required this.controller, this.onChanged, this.factor});

  /// 给予子元素的传入宽度的分数
  final double? factor;

  /// 编辑器字段的控制器
  final CodeLineEditingController controller;

  /// 当用户发起对编辑器的值被更改，例如插入或删除
  final ValueChanged<CodeLineEditingValue>? onChanged;

  @override
  State<StatefulWidget> createState() => PostContentState();
}

class PostContentState extends State<PostContent> {
  /// 主题数据
  late final theme = Theme.of(context);

  // 按钮样式
  late final buttonStyle = ButtonStyle(
    textStyle: WidgetStatePropertyAll(theme.textTheme.bodySmall),
    iconSize: WidgetStatePropertyAll(14),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    fixedSize: WidgetStatePropertyAll(Size.square(24)),
    minimumSize: WidgetStatePropertyAll(Size.square(24)),
    shape: WidgetStatePropertyAll(CircleBorder()),
    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
  );

  /// 查找模式
  final Map<Widget, RxBool> modes = {};

  /// 查找控制器
  late final CodeFindController findController = CodeFindController(widget.controller);

  /// 上下文菜单的标题样式
  late final titleStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);

  @override
  void initState() {
    super.initState();
    modes[const Icon(PhosphorIconsRegular.textAa)] = false.obs;
    modes[const Text('.*')] = false.obs;
  }

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.bodyMedium?.apply(fontSizeFactor: 1.1);
    return CodeEditor(
      autofocus: false,
      controller: widget.controller,
      findController: findController,
      hint: Tran.startWriting.tr,
      padding: kTopPadding16.flipped,
      onChanged: widget.onChanged,
      findBuilder: buildFind,
      scrollbarBuilder: buildScrollbar,
      toolbarController: PostContextMenuController.create(builder: buildContextMenu),
      style: CodeEditorStyle(
        fontSize: style?.fontSize,
        fontFamily: style?.fontFamily,
        hintTextColor: theme.colorScheme.outlineVariant,
        codeTheme: CodeHighlightTheme(
          languages: {
            'md': CodeHighlightThemeMode(mode: _langMarkdown),
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

  /// 构建查找和替换
  PreferredSizeWidget buildFind(BuildContext context, CodeFindController controller, bool readOnly) {
    if (controller.value == null) {
      return PreferredSize(preferredSize: Size.zero, child: Container());
    }
    // 替换模式
    final isReplace = controller.value!.replaceMode && !readOnly;
    // 搜索
    Widget child = _getInput(
      controller: controller.findInputController,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var MapEntry(:key, :value) in modes.entries) _getIconButton(value, key, controller),
        ],
      ),
    );
    // 操作
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        TextButton(onPressed: controller.previousMatch, child: const Icon(PhosphorIconsRegular.arrowLeft)),
        TextButton(onPressed: controller.nextMatch, child: const Icon(PhosphorIconsRegular.arrowRight)),
        TextButton(onPressed: controller.close, child: const Icon(PhosphorIconsRegular.x)),
      ],
    );
    // 布局
    child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [child, if (isReplace) _getReplace(controller)],
    );
    // 切换替换模式
    child = Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: controller.toggleMode, child: Icon(isReplace ? PhosphorIconsRegular.arrowFatDown : PhosphorIconsRegular.arrowFatRight)),
        child,
      ],
    );
    // 卡片
    child = Card(shape: Border(), child: Padding(padding: kAllPadding8 / 2, child: child));
    // 添加按钮样式
    child = TextButtonTheme(data: TextButtonThemeData(style: buttonStyle), child: child);
    // 添加 IntrinsicWidth
    child = IntrinsicWidth(stepWidth: 10, stepHeight: 10, child: child);
    // 位置
    child = Stack(
      alignment: Alignment.topRight,
      children: [Positioned(top: 0, right: 0, child: child)],
    );
    return PreferredSize(preferredSize: Size.zero, child: child);
  }

  /// 获取输入框
  Widget _getInput({TextEditingController? controller, Widget? child}) {
    return TextFormField(
      controller: controller,
      style: theme.textTheme.bodySmall,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kHorPadding8 + kVerPadding4,
        hoverColor: Colors.transparent,
        // 悬停时的背景色
        constraints: const BoxConstraints.tightFor(width: 300),
        suffixIcon: child,
        suffixIconConstraints: const BoxConstraints(),
      ),
    );
  }

  /// 替换输入框
  Widget _getReplace(CodeFindController controller) {
    // 替换
    Widget child = _getInput(controller: controller.replaceInputController);
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        TextButton(onPressed: controller.replaceMatch, child: const Icon(PhosphorIconsRegular.boundingBox)),
        TextButton(onPressed: controller.replaceAllMatches, child: const Icon(PhosphorIconsRegular.swap)),
      ],
    );
    return child;
  }

  /// 获取按钮以及按钮样式
  Widget _getIconButton(RxBool enable, Widget child, CodeFindController controller) {
    final colors = theme.colorScheme;
    final prop = WidgetStateProperty.resolveWith((states) => enable.value ? colors.primary : colors.onSurface);
    return TextButton(
      onPressed: () {
        enable.value = !enable.value;
        if (child is Text) {
          controller.toggleRegex();
        } else {
          controller.toggleCaseSensitive();
        }
      },
      style: ButtonStyle(iconColor: prop, foregroundColor: prop),
      child: child,
    );
  }

  /// 构建上下文菜单
  Widget buildContextMenu({
    required BuildContext context,
    required TextSelectionToolbarAnchors anchors,
    required CodeLineEditingController controller,
    required VoidCallback onDismiss,
    required VoidCallback onRefresh,
  }) {
    final colors = theme.colorScheme;
    final padding = kHorPadding8 + kVerPadding4;
    final constraints = const BoxConstraints.expand(height: 30);
    // 构建子项控件
    Widget buildItem(TActionKey item) {
      return ListItem(
        dense: true,
        title: Text(item.name, style: titleStyle),
        trailing: Text(item.key, style: titleStyle),
        constraints: constraints,
        contentPadding: padding,
        selectedTileColor: colors.primary,
        selectedColor: colors.surfaceContainerLow,
        onTap: () {
          item.call();
          onDismiss();
        },
      );
    }

    // 选项
    final List<List<TActionKey>> items = [
      [
        (name: '剪切', key: 'Ctrl+X', call: controller.cut),
        (name: '复制', key: 'Ctrl+C', call: controller.copy),
        (name: '粘贴', key: 'Ctrl+V', call: controller.paste),
      ],
      [
        (name: '查找', key: 'Ctrl+F', call: findController.findMode),
        (name: '替换', key: 'Ctrl+Alt+F', call: findController.replaceMode),
      ],
    ];
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: items.expandIndexed((index, item) {
        return [
          if (index > 0) Padding(padding: kVerPadding4, child: const Divider(height: 1, thickness: 1)),
          for (var value in item) buildItem(value),
        ];
      }).toList(),
    );
    child = SizedBox(width: 200, child: child);
    return child;
  }
}

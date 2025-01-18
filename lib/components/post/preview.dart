import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownBody, MarkdownStyleSheet;
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart' show LatexElementBuilder;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/post.dart';

/// 预览 [Post]
class PostPreview extends DrawerEditor<Post> {
  const PostPreview({
    super.key,
    required super.entity,
    super.controller,
    super.header = '',
    super.showAction = false,
    required this.markdown,
  });

  /// markdown 内容
  final String markdown;

  @override
  DrawerEditorState<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends DrawerEditorState<PostPreview> {
  /// 时间文本
  late final dateText = widget.entity.date.format(pattern: site.themeConfig.dateFormat);

  /// 时间文本的样式
  late final dateStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline);

  /// 定义要为哪些 Markdown 元素使用哪些 TextStyle 对象
  late final MarkdownStyleSheet styleSheet = createStyle();

  /// 构建控件的函数集合
  late final _buildFun = <ValueGetter<Widget>>{
    _buildFeature,
    _buildTitle,
    _buildDate,
    if (widget.entity.tags.isNotEmpty) _buildTags,
    _buildView,
  };

  @override
  Widget? buildContent(BuildContext context, int index) {
    final child = _buildFun.elementAtOrNull(index)?.call();
    return child != null ? wrapperField(child: child) : null;
  }

  /// 封面
  Widget _buildFeature() => ImageConfig.builderImg(site.getFeaturePath(widget.entity));

  /// 标题
  Widget _buildTitle() => Text(widget.entity.title, style: theme.textTheme.headlineMedium);

  /// 创建时间
  Widget _buildDate() => Text(dateText, style: dateStyle);

  /// 构建标签
  Widget _buildTags() {
    return Row(
      spacing: kHorPadding8.right,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var tag in site.getTagsWithPost(widget.entity))
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.onInverseSurface,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: kVerPadding4 + kHorPadding8,
              child: Text(tag.name, style: theme.textTheme.bodySmall),
            ),
          ),
      ],
    );
  }

  /// 构建 MarkDown 视图
  Widget _buildView() {
    return MarkdownBody(
      selectable: true,
      fitContent: false,
      data: widget.markdown,
      styleSheet: styleSheet,
      builders: {
        'latex': LatexElementBuilder(
          textStyle: theme.textTheme.bodyMedium,
          textScaleFactor: 1.2,
        ),
      },
      extensionSet: Markdown.preview,
    );
  }

  /// 创建样式
  MarkdownStyleSheet createStyle() {
    var style = MarkdownStyleSheet.fromTheme(theme);
    style = style.copyWith(
      pPadding: kVerPadding4,
      h1Padding: kVerPadding4,
      h2Padding: kVerPadding4,
      h3Padding: kVerPadding4,
      h4Padding: kVerPadding4,
      h5Padding: kVerPadding4,
      h6Padding: kVerPadding4,
      code: style.code?.copyWith(fontSize: style.p?.fontSize),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2.0),
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.secondaryHeaderColor, //Colors.blue.shade100,
        borderRadius: BorderRadius.circular(2.0),
      ),
      textScaler: const TextScaler.linear(1.1),
    );
    return style;
  }
}

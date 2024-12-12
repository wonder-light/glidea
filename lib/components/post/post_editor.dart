import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/post.dart';
import 'package:markdown_widget/markdown_widget.dart' show MarkdownConfig, MarkdownGenerator, MarkdownWidget;

/// 文章设置编辑器, 文章预览
class PostEditor extends DrawerEditor<Post> {
  const PostEditor({
    super.key,
    required super.entity,
    required super.controller,
    super.header = 'postSettings',
    super.showAction = false,
    this.preview = true,
    this.markdown,
  });

  /// 预览 post 文章
  final bool preview;

  /// markdown 内容
  final String? markdown;

  @override
  PostEditorState createState() => PostEditorState();
}

class PostEditorState extends DrawerEditorState<PostEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    Widget child;
    if (widget.preview) {
      child = _buildPreview();
    } else {
      child = _buildSetting();
    }
    // 加个滚动
    return [
      Expanded(
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    ];
  }

  /// 构建预览
  Widget _buildPreview() {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final post = widget.entity;
    final dateStr = post.date.format(pattern: site.themeConfig.dateFormat);
    final dateStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.outline);
    // 控件
    final List<Widget> children = [
      ImageConfig.builderImg(site.getFeaturePath(widget.entity)),
      Text(post.title, style: textTheme.headlineSmall),
      Text(dateStr, style: dateStyle),
      if (post.tags.isNotEmpty)
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var tag in post.tags)
              Container(
                padding: kVerPadding4 + kHorPadding8,
                decoration: BoxDecoration(
                  color: colorScheme.onInverseSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(tag.name, style: textTheme.bodySmall),
              ),
          ],
        ),
      MarkdownWidget(
        data: widget.markdown ?? '',
        shrinkWrap: true,
        config: MarkdownConfig(configs: [
          const ImageConfig(),
        ]),
        markdownGenerator: MarkdownGenerator(
          extensionSet: Markdown.custom,
          textGenerator: CustomTextNode.new,
        ),
      ),
    ];
    // 返回
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: i <= 0 ? kTopPadding8 : kTopPadding16,
            child: children[i],
          ),
      ],
    );
  }

  /// 设置视图
  Widget _buildSetting() {
  }
}

import 'package:flutter/material.dart';
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/post.dart';
import 'package:markdown_widget/markdown_widget.dart' show MarkdownConfig, MarkdownWidget;

/// 文章设置编辑器, 文章预览
class PostEditor extends DrawerEditor<Post> {
  const PostEditor({
    super.key,
    required super.entity,
    required super.controller,
    required this.markdown,
    super.header = 'postSettings',
    super.showAction = false,
    this.preview = true,
  });

  /// 预览 post 文章
  final bool preview;

  /// markdown 内容
  final String markdown;

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
    if (widget.preview) {
      return [
        Expanded(
          child: MarkdownWidget(
            data: widget.markdown,
            shrinkWrap: true,
            config: MarkdownConfig(configs: [
              const ImageConfig(),
            ]),
          ),
        ),
      ];
    }
    return [];
  }
}

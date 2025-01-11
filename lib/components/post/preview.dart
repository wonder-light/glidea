import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst;
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/post.dart';
import 'package:markdown_widget/markdown_widget.dart' show MarkdownConfig, MarkdownGenerator, MarkdownWidget;

class PostPreview extends StatefulWidget {
  const PostPreview({super.key, required this.entity, required this.markdown});

  /// 实体
  final Post entity;

  /// markdown 内容
  final String markdown;

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 主题颜色
  late final theme = Theme.of(Get.context!);

  @override
  Widget build(BuildContext context) {
    // TODO: 改善性能 - 使用 WebView 或者其它方式, 添加 Latex 支持
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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
            for (var tag in site.getTagsWithPost(post))
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
}

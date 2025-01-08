import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart' show HtmlWidget;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:markdown/markdown.dart' as m
    show HeaderSyntax, Node, BlockParser, SetextHeaderSyntax, Element, ExtensionSet, Resolver, BlockSyntax, renderToHtml, Document, InlineSyntax;
import 'package:markdown_widget/markdown_widget.dart' show ElementNode, ImgConfig, MarkdownConfig, SpanNode, TextNode, WidgetVisitor;

/// 解析 ajax 样式的头，并将生成的id添加到生成的元素中
///
/// Parses atx-style headers, and adds generated IDs to the generated elements.
class HeaderWithId extends m.HeaderSyntax {
  const HeaderWithId();

  @override
  m.Node parse(m.BlockParser parser) {
    final element = super.parse(parser) as m.Element;

    if (element.children?.isNotEmpty ?? false) {
      element.generatedId = Uid.shortId;
    }

    return element;
  }
}

/// 解析 setext 样式的头，并将生成的id添加到生成的元素中
///
/// Parses setext-style headers, and adds generated IDs to the generated elements.
class SetextHeaderWithId extends m.SetextHeaderSyntax {
  const SetextHeaderWithId();

  @override
  m.Node parse(m.BlockParser parser) {
    final element = super.parse(parser) as m.Element;
    element.generatedId = Uid.shortId;
    return element;
  }
}

/// [m.Element] 的扩展
extension ElementExt on m.Element {
  /// 检测当前元素是否是 Toc 的一部分
  bool get isToc {
    return (generatedId?.isNotEmpty ?? false) && RegExp(r'h[1-7]').hasMatch(tag);
  }
}

/// [Markdown] 工具扩展
class Markdown {
  /// 自定义扩展集
  static final m.ExtensionSet custom = m.ExtensionSet(
    [
      m.ExtensionSet.gitHubWeb.blockSyntaxes[0],
      const HeaderWithId(),
      const SetextHeaderWithId(),
      ...m.ExtensionSet.gitHubWeb.blockSyntaxes.skip(3),
    ],
    m.ExtensionSet.gitHubWeb.inlineSyntaxes,
  );

  /// 将给定的 Markdown 字符串转换为HTML
  static String markdownToHtml(
    String markdown, {
    Iterable<m.BlockSyntax> blockSyntaxes = const [],
    Iterable<m.InlineSyntax> inlineSyntaxes = const [],
    m.ExtensionSet? extensionSet,
    m.Resolver? linkResolver,
    m.Resolver? imageLinkResolver,
    ValueSetter<String>? tocCallback,
    bool inlineOnly = false,
    bool encodeHtml = true,
    bool enableTagFilter = false,
    bool withDefaultBlockSyntaxes = true,
    bool withDefaultInlineSyntaxes = true,
  }) {
    final document = m.Document(
      blockSyntaxes: blockSyntaxes,
      inlineSyntaxes: inlineSyntaxes,
      extensionSet: extensionSet ?? custom,
      linkResolver: linkResolver,
      imageLinkResolver: imageLinkResolver,
      encodeHtml: encodeHtml,
      withDefaultBlockSyntaxes: withDefaultBlockSyntaxes,
      withDefaultInlineSyntaxes: withDefaultInlineSyntaxes,
    );

    if (inlineOnly) return m.renderToHtml(document.parseInline(markdown));

    final nodes = document.parse(markdown);

    if (tocCallback != null) {
      tocCallback(getToc(nodes, document, enableTagFilter: enableTagFilter));
    }

    return '${m.renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }

  /// 获取目录
  static String getToc(List<m.Node> nodes, m.Document doc, {bool enableTagFilter = false}) {
    String str = '';
    int initRank = 10;
    for (var item in nodes) {
      if (item is m.Element && item.isToc) {
        // 级别 h1 => 1, h2 => 2
        var rank = int.tryParse(item.tag.substring(1));
        if (rank == null) continue;
        if (rank < initRank) initRank = rank;
        // h2 => * [标题名称](#generatedId)
        str += '${"  " * (rank - initRank)}* [${item.textContent}](#${item.generatedId})\n';
      }
    }

    nodes = doc.parse(str);
    return '${m.renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }
}

class CustomTextNode extends ElementNode {
  final m.Node element;

  //final String nodeText;
  final MarkdownConfig config;
  final WidgetVisitor visitor;
  bool isHtml = false;
  static final RegExp tableRep = RegExp(r'<table[^>]*>', multiLine: true, caseSensitive: true);

  static final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

  CustomTextNode(this.element, this.config, this.visitor);

  @override
  InlineSpan build() {
    try {
      // HTML
      if (isHtml) {
        return WidgetSpan(child: buildHtml());
      }
      return super.build();
    } catch (e) {
      // 文本样式
      final textStyle = config.p.textStyle.merge(parentStyle);
      // 显示文本
      return TextSpan(children: [
        TextNode(text: element.textContent, style: textStyle).build(),
      ]);
    }
  }

  @override
  void onAccepted(SpanNode parent) {
    String nodeText = element.textContent;

    children.clear();
    // 没有 html 元素
    isHtml = nodeText.contains(htmlRep);
    if (isHtml) {
      accept(parent);
    }
    if (!isHtml) {
      // 文本样式
      final textStyle = config.p.textStyle.merge(parentStyle);
      accept(TextNode(text: nodeText, style: textStyle));
    }
  }

  /// 构建 HTML
  Widget buildHtml() {
    return HtmlWidget(
      element.textContent,
      customStylesBuilder: (el) {
        switch (el.localName) {
          case 'table':
            return {'border': '1px solid', 'border-collapse': 'collapse'};
          case 'th':
          case 'td':
            return {'border': '1px solid', 'padding': '8px'};
        }
        return null;
      },
    );
  }
}

/// config class for image, tag: img
class ImageConfig extends ImgConfig {
  const ImageConfig({super.builder = _defaultBuildImg, super.errorBuilder});

  /// 默认构建图片
  static Widget _defaultBuildImg(String url, Map<String, String>? attributes) => builderImg(url, attributes: attributes);

  /// 构建图片
  static Widget builderImg(String url, {Map<String, String>? attributes, BoxFit fit = BoxFit.cover}) {
    if (url.isEmpty) {
      return Image.asset('assets/images/upload_image.jpg', errorBuilder: buildError);
    }
    // 网络图片
    if (url.startsWith('http')) {
      return Image.network(url, fit: fit, errorBuilder: buildError);
    }
    // 网络图片
    if (url.startsWith('assets')) {
      Image.asset(url, fit: fit, errorBuilder: buildError);
    }
    // post 中的本地图片
    if (url.startsWith(featurePrefix)) {
      url = url.substring(featurePrefix.length);
    }
    return Image(image: FileImageExpansion.file(url), fit: fit, errorBuilder: buildError);
  }

  /// 图片加载失败时的占位图
  static Widget buildError(BuildContext context, Object error, StackTrace? stacktrace) {
    return Image.asset('assets/images/loading_error.png');
  }
}

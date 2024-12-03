import 'package:flutter/material.dart' show ValueSetter;
import 'package:glidea/helpers/uid.dart';
import 'package:markdown/markdown.dart'
    show BlockParser, BlockSyntax, Document, Element, ExtensionSet, HeaderSyntax, InlineSyntax, Node, Resolver, SetextHeaderSyntax, renderToHtml;

/// 解析 ajax 样式的头，并将生成的id添加到生成的元素中
///
/// Parses atx-style headers, and adds generated IDs to the generated elements.
class HeaderWithId extends HeaderSyntax {
  const HeaderWithId();

  @override
  Node parse(BlockParser parser) {
    final element = super.parse(parser) as Element;

    if (element.children?.isNotEmpty ?? false) {
      element.generatedId = Uid.shortId;
    }

    return element;
  }
}

/// 解析 setext 样式的头，并将生成的id添加到生成的元素中
///
/// Parses setext-style headers, and adds generated IDs to the generated elements.
class SetextHeaderWithId extends SetextHeaderSyntax {
  const SetextHeaderWithId();

  @override
  Node parse(BlockParser parser) {
    final element = super.parse(parser) as Element;
    element.generatedId = Uid.shortId;
    return element;
  }
}

extension ElementExt on Element {
  /// 检测当前元素是否是 Toc 的一部分
  bool get isToc {
    return (generatedId?.isNotEmpty ?? false) && RegExp(r'h[1-7]').hasMatch(tag);
  }
}

class Markdown {
  /// 自定义扩展集
  static final ExtensionSet custom = ExtensionSet(
    [
          ExtensionSet.gitHubWeb.blockSyntaxes[0],
          const HeaderWithId(),
          const SetextHeaderWithId(),
        ] +
        ExtensionSet.gitHubWeb.blockSyntaxes.skip(3).toList(),
    ExtensionSet.gitHubWeb.inlineSyntaxes,
  );

  /// 将给定的 Markdown 字符串转换为HTML
  static String markdownToHtml(
    String markdown, {
    Iterable<BlockSyntax> blockSyntaxes = const [],
    Iterable<InlineSyntax> inlineSyntaxes = const [],
    ExtensionSet? extensionSet,
    Resolver? linkResolver,
    Resolver? imageLinkResolver,
    ValueSetter<String>? tocCallback,
    bool inlineOnly = false,
    bool encodeHtml = true,
    bool enableTagFilter = false,
    bool withDefaultBlockSyntaxes = true,
    bool withDefaultInlineSyntaxes = true,
  }) {
    final document = Document(
      blockSyntaxes: blockSyntaxes,
      inlineSyntaxes: inlineSyntaxes,
      extensionSet: extensionSet ?? custom,
      linkResolver: linkResolver,
      imageLinkResolver: imageLinkResolver,
      encodeHtml: encodeHtml,
      withDefaultBlockSyntaxes: withDefaultBlockSyntaxes,
      withDefaultInlineSyntaxes: withDefaultInlineSyntaxes,
    );

    if (inlineOnly) return renderToHtml(document.parseInline(markdown));

    final nodes = document.parse(markdown);

    if (tocCallback != null) {
      tocCallback(getToc(nodes, document, enableTagFilter: enableTagFilter));
    }

    return '${renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }

  /// 获取目录
  static String getToc(List<Node> nodes, Document doc, {bool enableTagFilter = false}) {
    String str = '';
    int initRank = 10;
    for (var item in nodes) {
      if (item is Element && item.isToc) {
        // 级别 h1 => 1, h2 => 2
        var rank = int.tryParse(item.tag.substring(1));
        if (rank == null) continue;
        if (rank < initRank) initRank = rank;
        // h2 => * [标题名称](#generatedId)
        str += '${"  " * (rank - initRank)}* [${item.textContent}](#${item.generatedId})\n';
      }
    }

    nodes = doc.parse(str);
    return '${renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }
}

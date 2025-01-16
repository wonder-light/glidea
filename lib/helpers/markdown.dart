import 'package:flutter/material.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart' show LatexBlockSyntax, LatexInlineSyntax;
import 'package:glidea/helpers/json.dart';
import 'package:markdown/markdown.dart' as m show HeaderSyntax, Node, BlockParser, SetextHeaderSyntax, Element, ExtensionSet;
import 'package:markdown/markdown.dart' as m show Resolver, BlockSyntax, renderToHtml, Document, InlineSyntax;

/// 解析 ajax 样式的头，并将生成的id添加到生成的元素中
///
/// Parses atx-style headers, and adds generated IDs to the generated elements.
class HeaderWithId extends m.HeaderSyntax {
  const HeaderWithId();

  @override
  m.Node parse(m.BlockParser parser) {
    final element = super.parse(parser) as m.Element;

    if (element.children?.isNotEmpty ?? false) {
      final value = element.textContent.getBase64();
      element.generatedId = value.substring(0, value.length >= 12 ? 12 : value.length);
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
    final value = element.textContent.getBase64();
    element.generatedId = value.substring(0, value.length >= 12 ? 12 : value.length);
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
      LatexBlockSyntax(),
    ],
    [...m.ExtensionSet.gitHubWeb.inlineSyntaxes, LatexInlineSyntax()],
  );

  /// 将给定的 Markdown 字符串转换为HTML
  static String markdownToHtml(
    String markdown, {
    Iterable<m.BlockSyntax>? blockSyntaxes,
    Iterable<m.InlineSyntax>? inlineSyntaxes,
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
    // 生成 nodes
    nodes = doc.parse(str);
    // 添加 class
    if (nodes.firstOrNull case m.Element ul) {
      ul.attributes['class'] = 'markdown-toc';
    }
    return '${m.renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }
}

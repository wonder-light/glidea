import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:html/dom.dart' as h;
import 'package:html/dom_parsing.dart' show TreeVisitor;
import 'package:html/parser.dart' show parseFragment;
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

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
  bool isTable = false;
  static final RegExp tableRep = RegExp(r'<table[^>]*>', multiLine: true, caseSensitive: true);

  static final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

  CustomTextNode(this.element, this.config, this.visitor);

  @override
  InlineSpan build() {
    try {
      // HTML
      if (isTable) {
        return WidgetSpan(
          child: HtmlWidget(element.textContent),
        );
      }
      return super.build();
    } catch (e) {
      // 显示文本
      return TextSpan(children: [
        TextNode(text: element.textContent, style: style).build(),
      ]);
    }
  }

  @override
  void onAccepted(SpanNode parent) {
    String nodeText = element.textContent;
    // 文本样式
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    // 没有 html 元素
    if (!nodeText.contains(htmlRep)) {
      accept(TextNode(text: nodeText, style: textStyle));
      return;
    }
    //截距表标记
    if (nodeText.contains(tableRep)) {
      nodeText = nodeText.replaceAll(RegExp(r'[\n\r\s]'), '');
      isTable = true;
      accept(parent);
    }

    //其余的由常规HTML处理处理
    final spans = parseHtml(nodeText: nodeText, parentStyle: parentStyle);
    for (var element in spans) {
      isTable = false;
      accept(element);
    }
  }

  ///parse [m.Node] to [h.Node]
  List<SpanNode> parseHtml({required String nodeText, ValueCallback<dynamic>? onError, TextStyle? parentStyle}) {
    try {
      // 使用 WidgetVisitor，可以转换 MarkdownNode 到 SpanNodes, 你可以使用 SpanNode 与文本. rich 或 RichText 获取
      final vis = WidgetVisitor(
        config: visitor.config,
        generators: visitor.generators,
        richTextBuilder: visitor.richTextBuilder,
      );
      // 替换换行符
      final text = nodeText.replaceAll(vis.splitRegExp ?? WidgetVisitor.defaultSplitRegExp, '');
      // 没有 html 元素
      if (!text.contains(htmlRep)) return [TextNode(text: nodeText)];
      // 解析 html5 片段
      final document = parseFragment(text);
      return HtmlToSpanVisitor(visitor: vis, parentStyle: parentStyle).toVisit(document.nodes.toList());
    } catch (e) {
      onError?.call(e);
      return [TextNode(text: nodeText)];
    }
  }
}

/// 用于DOM节点的简单树访问器
class HtmlToSpanVisitor extends TreeVisitor {
  final List<SpanNode> _spans = [];
  final List<SpanNode> _spansStack = [];
  final WidgetVisitor visitor;
  final TextStyle parentStyle;

  HtmlToSpanVisitor({WidgetVisitor? visitor, TextStyle? parentStyle})
      : visitor = visitor ?? WidgetVisitor(),
        parentStyle = parentStyle ?? const TextStyle();

  List<SpanNode> toVisit(List<h.Node> nodes) {
    _spans.clear();
    for (final node in nodes) {
      if (node case h.Element e when e.localName == 'link' || e.localName == 'script' || e.localName == 'style') {
        continue;
      }
      final emptyNode = ConcreteElementNode(style: parentStyle);
      _spans.add(emptyNode);
      _spansStack.add(emptyNode);
      visit(node);
      _spansStack.removeLast();
    }
    final result = List.of(_spans);
    _spans.clear();
    _spansStack.clear();
    return result;
  }

  @override
  void visitText(h.Text node) {
    final last = _spansStack.last;
    if (last is ElementNode) {
      final textNode = TextNode(text: node.text);
      last.accept(textNode);
    }
  }

  @override
  void visitElement(h.Element node) {
    final localName = node.localName ?? '';
    final mdElement = m.Element(localName, []);
    mdElement.attributes.addAll(node.attributes.cast());
    SpanNode spanNode = visitor.getNodeByElement(mdElement, visitor.config);
    if (spanNode is! ElementNode) {
      final n = ConcreteElementNode(tag: localName, style: parentStyle);
      n.accept(spanNode);
      spanNode = n;
    }
    final last = _spansStack.last;
    if (last is ElementNode) {
      last.accept(spanNode);
    }
    _spansStack.add(spanNode);
    for (var child in node.nodes.toList(growable: false)) {
      visit(child);
    }
    _spansStack.removeLast();
  }
}

/// config class for image, tag: img
class ImageConfig extends ImgConfig {
  const ImageConfig({super.builder = builderImg, super.errorBuilder});

  /// 构建图片
  static Widget builderImg(String url, Map<String, String> attributes) {
    const fit = BoxFit.cover;
    // 网络图片
    if (url.startsWith('http')) {
      return Image.network(url, fit: fit, errorBuilder: buildError);
    }
    // post 中的本地图片
    if (url.startsWith(featurePrefix)) {
      url = url.substring(featurePrefix.length);
      return Image(image: FileImageExpansion.file(url), fit: fit, errorBuilder: buildError);
    }
    // 资源图片
    return Image.asset(url, fit: fit, errorBuilder: buildError);
  }

  /// 图片加载失败时的占位图
  static Widget buildError(BuildContext context, Object error, StackTrace? stacktrace) {
    return Image.asset('assets/images/loading_error.png');
  }
}

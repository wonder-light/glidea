import 'package:flutter/material.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widget/markdown_widget.dart' show ImgConfig;

/// 解析 ajax 样式的头，并将生成的id添加到生成的元素中
///
/// Parses atx-style headers, and adds generated IDs to the generated elements.
class HeaderWithId extends md.HeaderSyntax {
  const HeaderWithId();

  @override
  md.Node parse(md.BlockParser parser) {
    final element = super.parse(parser) as md.Element;

    if (element.children?.isNotEmpty ?? false) {
      element.generatedId = Uid.shortId;
    }

    return element;
  }
}

/// 解析 setext 样式的头，并将生成的id添加到生成的元素中
///
/// Parses setext-style headers, and adds generated IDs to the generated elements.
class SetextHeaderWithId extends md.SetextHeaderSyntax {
  const SetextHeaderWithId();

  @override
  md.Node parse(md.BlockParser parser) {
    final element = super.parse(parser) as md.Element;
    element.generatedId = Uid.shortId;
    return element;
  }
}

/// [md.Element] 的扩展
extension ElementExt on md.Element {
  /// 检测当前元素是否是 Toc 的一部分
  bool get isToc {
    return (generatedId?.isNotEmpty ?? false) && RegExp(r'h[1-7]').hasMatch(tag);
  }
}

/// [Markdown] 工具扩展
class Markdown {
  /// 自定义扩展集
  static final md.ExtensionSet custom = md.ExtensionSet(
    [
      md.ExtensionSet.gitHubWeb.blockSyntaxes[0],
      const HeaderWithId(),
      const SetextHeaderWithId(),
      ...md.ExtensionSet.gitHubWeb.blockSyntaxes.skip(3),
    ],
    md.ExtensionSet.gitHubWeb.inlineSyntaxes,
  );

  /// 将给定的 Markdown 字符串转换为HTML
  static String markdownToHtml(
    String markdown, {
    Iterable<md.BlockSyntax> blockSyntaxes = const [],
    Iterable<md.InlineSyntax> inlineSyntaxes = const [],
    md.ExtensionSet? extensionSet,
    md.Resolver? linkResolver,
    md.Resolver? imageLinkResolver,
    ValueSetter<String>? tocCallback,
    bool inlineOnly = false,
    bool encodeHtml = true,
    bool enableTagFilter = false,
    bool withDefaultBlockSyntaxes = true,
    bool withDefaultInlineSyntaxes = true,
  }) {
    final document = md.Document(
      blockSyntaxes: blockSyntaxes,
      inlineSyntaxes: inlineSyntaxes,
      extensionSet: extensionSet ?? custom,
      linkResolver: linkResolver,
      imageLinkResolver: imageLinkResolver,
      encodeHtml: encodeHtml,
      withDefaultBlockSyntaxes: withDefaultBlockSyntaxes,
      withDefaultInlineSyntaxes: withDefaultInlineSyntaxes,
    );

    if (inlineOnly) return md.renderToHtml(document.parseInline(markdown));

    final nodes = document.parse(markdown);

    if (tocCallback != null) {
      tocCallback(getToc(nodes, document, enableTagFilter: enableTagFilter));
    }

    return '${md.renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
  }

  /// 获取目录
  static String getToc(List<md.Node> nodes, md.Document doc, {bool enableTagFilter = false}) {
    String str = '';
    int initRank = 10;
    for (var item in nodes) {
      if (item is md.Element && item.isToc) {
        // 级别 h1 => 1, h2 => 2
        var rank = int.tryParse(item.tag.substring(1));
        if (rank == null) continue;
        if (rank < initRank) initRank = rank;
        // h2 => * [标题名称](#generatedId)
        str += '${"  " * (rank - initRank)}* [${item.textContent}](#${item.generatedId})\n';
      }
    }

    nodes = doc.parse(str);
    return '${md.renderToHtml(nodes, enableTagfilter: enableTagFilter)}\n';
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

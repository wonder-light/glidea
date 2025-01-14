import 'package:xml/xml.dart';

abstract class _Xml {
  /// 根级元素
  Map<String, String> rootEntry = {};

  /// 元素实体
  List<_XmlEntry> entries = [];

  /// 初始化数据
  void setInit() {}

  /// 获取根元素
  XmlElement getRoot();

  /// 生成字符串
  String generate() {
    setInit();
    final root = XmlElement(XmlName('feed'), [
      XmlAttribute(XmlName('xmlns'), 'http://www.w3.org/2005/Atom'),
    ]);
    for (var MapEntry(:key, :value) in rootEntry.entries) {
      final entry = XmlElement(XmlName(key));
      entry.children.add(XmlText(value));
      root.children.add(entry);
    }
    for (var entry in entries) {
      final entryXml = XmlElement(XmlName(entry.rootName));
      for (var MapEntry(:key, :value) in entry.getAlternate().entries) {
        final child = XmlElement(XmlName(key));
        child.children.add(XmlText(value));
        entryXml.children.add(child);
      }
      root.children.add(entryXml);
    }
    return '<?xml version="1.0" encoding="utf-8"?>$root';
  }

  /// 添加实体
  _Xml add(_XmlEntry entry) {
    entries.add(entry);
    return this;
  }
}

abstract class _XmlEntry {
  /// [_XmlEntry] 的根的名称
  String rootName = '';

  Map<String, String> getAlternate();
}

/// Represents an entire Sitemap file.
class Sitemap extends _Xml {
  @override
  XmlElement getRoot() {
    return XmlElement(XmlName('urlset'), [
      XmlAttribute(XmlName('xmlns'), 'http://www.sitemaps.org/schemas/sitemap/0.9'),
      XmlAttribute(XmlName('xmlns:xhtml'), 'http://www.w3.org/1999/xhtml'),
    ]);
  }
}

/// Represents a single Sitemap entry.
class SitemapEntry extends _XmlEntry {
  SitemapEntry({
    this.location = '',
    this.changeFrequency = 'daily',
    this.priority = 0.5,
    DateTime? lastModified,
    Map<String, String> alternates = const {},
  })  : _alternates = alternates,
        lastModified = lastModified ?? DateTime.now();

  @override
  String get rootName => 'url';

  String location;
  DateTime lastModified = DateTime.now();
  String changeFrequency = 'daily';
  num priority = 0.5;

  final Map<String, String> _alternates;

  Map<String, String> get alternates => _alternates;

  void addAlternate(String language, String location) => _alternates[language] = location;

  @override
  Map<String, String> getAlternate() {
    return {
      'loc': location,
      'changefreq': changeFrequency,
      'priority': '$priority',
      'lastmod': '$lastModified',
      ...alternates,
    };
  }
}

class Feed extends _Xml {
  Feed({
    this.id = '',
    this.title = '',
    this.subtitle = '',
    this.link = '',
    this.logo = '',
    this.icon = '',
    this.rights = '',
    DateTime? updated,
  }) : updated = updated ?? DateTime.now();

  /// url 地址
  ///
  ///     http://localhost:4000/
  String id;

  /// 标题
  String title;

  /// 子标题
  String subtitle;

  /// url 地址
  ///
  ///     http://localhost:4000/
  String link;

  /// 更新时间
  DateTime updated;

  /// logo
  String logo;

  /// 图标
  String icon;

  /// 版权声明
  String rights;

  @override
  XmlElement getRoot() {
    return XmlElement(XmlName('feed'), [
      XmlAttribute(XmlName('xmlns'), 'http://www.w3.org/2005/Atom'),
    ]);
  }

  @override
  void setInit() {
    rootEntry.clear();
    rootEntry.addAll({
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'link': link,
      'logo': logo,
      'icon': icon,
      'rights': rights,
      'updated': updated.toString(),
    });
  }
}

class FeedEntry extends _XmlEntry {
  FeedEntry({
    this.id = '',
    this.title = '',
    this.link = '',
    DateTime? updated,
    this.content = '',
  }) : updated = updated ?? DateTime.now();

  @override
  String get rootName => 'entry';

  /// url 地址
  ///
  ///     http://localhost:4000/
  String id;

  /// 标题
  String title;

  /// url 地址
  ///
  ///     http://localhost:4000/
  String link;

  /// 更新时间
  DateTime updated;

  /// 内容
  String content;

  @override
  Map<String, String> getAlternate() {
    return {
      'title': title,
      'id': id,
      'link': link,
      'updated': updated.toString(),
      'content': content,
    };
  }
}

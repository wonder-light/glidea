import 'package:flutter/material.dart';

const int defaultPostPageSize = 10;
const int defaultArchivesPageSize = 50;
const int defaultFeedCount = 10;
const String defaultFaviconPath = 'favicon.ico';
const String defaultAvatarPath = 'images/avatar.png';
const String defaultArchivePath = 'archives';
const String defaultPostPath = 'post';
const String defaultTagPath = 'tag';
const String defaultPostFeaturePath = '/post-images/post-feature.jpg';
const String defaultRobotsPath = 'User-agent: *\nDisallow:';
const String defaultDateFormat = 'yyyy-MM-dd';

// 模板名称
const homeTemplate = 'index.j2';
const postTemplate = 'post.j2';
const archivesTemplate = 'archives.j2';
const tagsTemplate = 'tags.j2';
const tagTemplate = 'tag.j2';

/// 加载 [Post] 中的本地图片的前缀
const String featurePrefix = 'file://';

/// 摘要分隔符
const String summarySeparator = '<!-- more -->';

/// 摘要分隔符的正则匹配
final RegExp summaryRegExp = RegExp(r'<!--\s*more\s*-->');

/// 主题设置图片显示的最大宽度
const double kImageWidth = 100;

/// 面板宽度
const double kPanelWidth = 200;

/// log大小
const double kLogSize = 64;

/// 默认按钮高度
const double kButtonHeight = 36;

/// 分隔列表的高度
const double listSeparated = 10;

/// 10Mb 文件大小
const int fileSize10M = 10 * 1024 * 1024;

const double windowMinWidth = 740;
const double windowMinHeight = 600;

/// 图片类型扩展
const List<String> imageExt = ['jpg', 'jpeg', 'png', 'bmp', 'webp', 'gif', 'tif', 'tiff', 'apng', 'jfif', 'avif'];

const EdgeInsets kAllPadding16 = EdgeInsets.all(16);
const EdgeInsets kHorPadding8 = EdgeInsets.symmetric(horizontal: 8);
const EdgeInsets kHorPadding12 = EdgeInsets.symmetric(horizontal: 12);
const EdgeInsets kHorPadding16 = EdgeInsets.symmetric(horizontal: 16);
const EdgeInsets kVerPadding4 = EdgeInsets.symmetric(vertical: 4);
const EdgeInsets kVerPadding8 = EdgeInsets.symmetric(vertical: 8);
const EdgeInsets kVerPadding16 = EdgeInsets.symmetric(vertical: 16);
const EdgeInsets kRightPadding4 = EdgeInsets.only(right: 4);
const EdgeInsets kRightPadding8 = EdgeInsets.only(right: 8);
const EdgeInsets kRightPadding16 = EdgeInsets.only(right: 16);
const EdgeInsets kTopPadding8 = EdgeInsets.only(top: 8);
const EdgeInsets kTopPadding16 = EdgeInsets.only(top: 16);
const EdgeInsets kVer8Hor12 = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
const EdgeInsets kVer12Hor24 = EdgeInsets.symmetric(vertical: 12, horizontal: 24);
const EdgeInsets kVer24Hor16 = EdgeInsets.symmetric(vertical: 24, horizontal: 16);
const EdgeInsets kVer8Hor32 = EdgeInsets.symmetric(vertical: 8, horizontal: 32);

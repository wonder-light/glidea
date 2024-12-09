import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';

@jsonSerializable
class Theme {
  /// 选择的主题名
  @JsonProperty()
  String selectTheme = '';

  /// 网页图标的路径
  @JsonProperty()
  String faviconSetting = defaultFaviconPath;

  /// 头像配置的路径
  @JsonProperty()
  String avatarSetting = defaultAvatarPath;

  /// 首页每一页显示的文章数量
  @JsonProperty()
  int postPageSize = defaultPostPageSize;

  /// 归档每一页显示的文章数量
  @JsonProperty()
  int archivesPageSize = defaultArchivesPageSize;

  /// 站点名称
  @JsonProperty()
  String siteName = '';

  /// 站点描述
  @JsonProperty()
  String siteDescription = '';

  /// 底部信息
  @JsonProperty()
  String footerInfo = 'Powered by Glidea';

  /// 显示封面图
  @JsonProperty()
  bool showFeatureImage = true;

  /// 主站 URL
  @JsonProperty()
  String domain = '';

  /// 文章 URL 格式
  @JsonProperty()
  UrlFormats postUrlFormat = UrlFormats.slug;

  /// 标签 URL 格式
  @JsonProperty()
  UrlFormats tagUrlFormat = UrlFormats.shortId;

  /// 时间格式
  @JsonProperty()
  String dateFormat = defaultDateFormat;

  /// true: 启用 RSS/Feed
  ///
  /// false: 关闭 RSS/Feed
  @JsonProperty()
  bool useFeed = true;

  /// Feed 的文章数量
  @JsonProperty()
  int feedCount = defaultFeedCount;

  /// 归档路径
  @JsonProperty()
  String archivePath = defaultArchivePath;

  /// 文章路径
  @JsonProperty()
  String postPath = defaultPostPath;

  /// 标签路径
  @JsonProperty()
  String tagPath = defaultTagPath;

  /// 创建站点地图
  @JsonProperty()
  bool generateSiteMap = true;

  /// robots 文本
  @JsonProperty()
  String robotsText = defaultRobotsPath;
}

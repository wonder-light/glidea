import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/helpers/constants.dart';

@jsonSerializable
class Theme {
  /// 主题名
  @JsonProperty()
  String themeName = '';

  /// 首页每一页显示的文章数量
  @JsonProperty()
  int postPageSize = Constants.DEFAULT_POST_PAGE_SIZE;

  /// 归档每一页显示的文章数量
  @JsonProperty()
  int archivesPageSize = Constants.DEFAULT_ARCHIVES_PAGE_SIZE;

  /// 站点名
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
  String postUrlFormat = 'SLUG';

  /// 标签 URL 格式
  @JsonProperty()
  String tagUrlFormat = 'SLUG';

  /// 时间格式
  @JsonProperty()
  String dateFormat = 'YYYY-MM-DD';

  /// 创建 Feed 文本
  @JsonProperty()
  bool feedFullText = true;

  /// Feed 的文章数量
  @JsonProperty()
  int feedCount = Constants.DEFAULT_FEED_COUNT;

  /// 归档路径
  @JsonProperty()
  String archivesPath = Constants.DEFAULT_ARCHIVES_PATH;

  /// 文章路径
  @JsonProperty()
  String postPath = Constants.DEFAULT_POST_PATH;

  /// 标签路径
  @JsonProperty()
  String tagPath = Constants.DEFAULT_TAG_PATH;

  /// 创建站点地图
  @JsonProperty()
  bool generateSiteMap = true;

  /// robots 文本
  @JsonProperty()
  String robotsText = Constants.DEFAULT_ROBOTS_TEXT;
}

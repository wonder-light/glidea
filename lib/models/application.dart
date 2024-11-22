import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/setting.dart';
import 'package:glidea/models/tag.dart';
import 'package:glidea/models/theme.dart';

/// 应用 Db
@jsonSerializable
class ApplicationDb {
  ///文章列表
  @JsonProperty()
  List<PostDb> posts = [];

  ///标签列表
  @JsonProperty()
  List<Tag> tags = [];

  ///菜单列表
  @JsonProperty()
  List<Menu> menus = [];

  ///主题李彪
  @JsonProperty()
  List<String> themes = [];

  ///主题配置
  @JsonProperty()
  Theme themeConfig = Theme();

  ///自定义主题配置
  @JsonProperty()
  Map<String, dynamic> themeCustomConfig = {};

  ///设置
  @JsonProperty()
  Setting setting = Setting();

  ///评论设置
  @JsonProperty()
  CommentSetting commentSetting = CommentSetting();

  ///当前主题配置
  @JsonProperty()
  Map<String, dynamic> currentThemeConfig = {};

  ///其它主题配置
  @JsonProperty()
  Map<String, dynamic> config = {};
}

/// APP 应用
@jsonSerializable
class Application {
  ///基本目录
  @JsonProperty()
  String baseDir = '';

  ///app目录
  @JsonProperty()
  String appDir = '';

  ///构建输出目录
  @JsonProperty()
  String buildDir = '';

  ///APP db
  @JsonProperty()
  ApplicationDb db = ApplicationDb();
}

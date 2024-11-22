import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/setting.dart';
import 'package:glidea/models/tag.dart';
import 'package:glidea/models/theme.dart';

/// 需要序列化存储的应用配置
@jsonSerializable
class ApplicationBase {
  ///文章列表
  @JsonProperty()
  List<Post> posts = [];

  ///标签列表
  @JsonProperty()
  List<Tag> tags = [];

  ///菜单列表
  @JsonProperty()
  List<Menu> menus = [];

  ///主题配置
  @JsonProperty()
  Theme themeConfig = Theme();

  ///自定义主题配置
  @JsonProperty()
  Map<String, dynamic> themeCustomConfig = {};

  ///远程设置
  @JsonProperty()
  RemoteSetting remote = RemoteSetting();

  ///评论设置
  @JsonProperty()
  CommentSetting comment = CommentSetting();
}

/// 应用 Db
@jsonSerializable
class ApplicationDb extends ApplicationBase {
  ///主题文件夹下存在的主题名字列表
  @JsonProperty()
  List<String> themes = [];

  ///其它主题配置
  @JsonProperty()
  Map<String, dynamic> config = {};
}

/// APP 应用设置
@jsonSerializable
mixin class ApplicationSetting {
  ///基本目录
  @JsonProperty()
  String baseDir = '';

  ///app目录
  @JsonProperty()
  String appDir = '';

  ///构建输出目录
  @JsonProperty()
  String buildDir = '';
}

/// APP 应用
@jsonSerializable
class Application extends ApplicationDb with ApplicationSetting {}

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

  ///语言代码, 例如
  ///
  /// ch_ZN, ch_TW
  @JsonProperty()
  String language = '';

  /// 预览端口
  @JsonProperty()
  int previewPort = 4000;
}

/// APP 应用设置
@jsonSerializable
mixin class ApplicationSetting {
  ///基本目录 - 当前应用所在的目录
  @JsonProperty()
  String baseDir = '';

  ///app目录
  @JsonProperty()
  String appDir = '';

  ///构建输出目录
  @JsonProperty()
  String buildDir = '';

  ///应用程序支持的目录 - ApplicationSupportDirectory
  @JsonProperty()
  String supportDir = '';
}

/// APP 信息, 包含版本等
mixin class ApplicationInfo {
  /// app 名称
  String appName = '';

  /// package 名称
  String packageName = '';

  /// 软件包版本。从 [pubspec.yaml] 中的版本生成
  String version = '';

  /// 构建号。从 [pubspec.yaml] 中的版本生成
  String buildNumber = '';
}

/// APP 应用
@jsonSerializable
class Application extends ApplicationDb with ApplicationSetting, ApplicationInfo {}

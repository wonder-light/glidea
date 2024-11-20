import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/models/tag.dart';

/// 统计数据
@jsonSerializable
class Stats {
  /// 文本
  @JsonProperty()
  String text = '';

  /// 分钟数
  @JsonProperty()
  int minutes = 0;

  /// 时间
  @JsonProperty()
  int time = 0;

  /// 字数
  @JsonProperty()
  int words = 0;
}

/// 封面图片
@jsonSerializable
class FeatureImage {
  /// 图片名
  @JsonProperty()
  String? name;

  /// 图片路径
  @JsonProperty()
  String? path;

  /// 图片类型
  @JsonProperty()
  String? type;
}

/// 文章
@jsonSerializable
class Post {
  /// 内容
  @JsonProperty()
  String content = '';

  /// 文件名
  @JsonProperty()
  String fileName = '';

  /// 标题
  @JsonProperty()
  String title = '';

  /// 数据
  @JsonProperty()
  String date = '';

  /// 已发布
  @JsonProperty()
  bool published = false;

  /// 隐藏
  @JsonProperty()
  bool hideInList = false;

  /// 置顶
  @JsonProperty()
  bool isTop = false;

  /// 封面图片
  @JsonProperty()
  FeatureImage featureImage = FeatureImage();

  /// 外链封面图
  @JsonProperty()
  String featureImagePath = '';

  /// 删除文件名
  @JsonProperty()
  String deleteFileName = '';

  /// 标签
  @JsonProperty()
  List<String> tags = [];
}

/// 文章数据
@jsonSerializable
class PostData {
  /// 标题
  @JsonProperty()
  String title = '';

  /// 数据
  @JsonProperty()
  String date = '';

  /// 封面图
  @JsonProperty()
  String feature = '';

  /// 已发布
  @JsonProperty()
  bool published = false;

  /// 隐藏
  @JsonProperty()
  bool hideInList = false;

  /// 置顶
  @JsonProperty()
  bool isTop = false;

  /// 标签
  @JsonProperty()
  List<Tag>? tags;
}

/// 文章 Db
@jsonSerializable
class PostDb {
  /// 内容
  @JsonProperty()
  String content = '';

  /// 文件名
  @JsonProperty()
  String fileName = '';

  /// 文章数据
  @JsonProperty()
  PostData data = PostData();

  /// 摘要
  @JsonProperty()
  String abstract = '';
}

/// 文章渲染数据
@jsonSerializable
class PostRenderData {
  /// 内容
  @JsonProperty()
  String content = '';

  /// 文件名
  @JsonProperty()
  String fileName = '';

  /// 摘要
  @JsonProperty()
  String abstract = '';

  /// 标题
  @JsonProperty()
  String title = '';

  /// 描述
  @JsonProperty()
  String description = '';

  /// 数据
  @JsonProperty()
  String date = '';

  /// 日期格式化
  @JsonProperty()
  String dateFormat = '';

  /// 封面图
  @JsonProperty()
  String feature = '';

  /// 文章链接
  @JsonProperty()
  String link = '';

  /// 隐藏
  @JsonProperty()
  bool hideInList = false;

  /// 置顶
  @JsonProperty()
  bool isTop = false;

  /// 目录
  @JsonProperty()
  String? toc;

  /// 统计数据
  @JsonProperty()
  Stats stats = Stats();

  /// 下一篇文章
  @JsonProperty()
  PostRenderData? nextPost;

  /// 上一篇文章
  @JsonProperty()
  PostRenderData? prevPost;

  /// 标签
  @JsonProperty()
  List<TagRenderData> tags = [];
}

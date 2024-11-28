import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/tag.dart';

/// 文章基本要素
@jsonSerializable
mixin class PostBase {
  /// 内容
  @JsonProperty()
  String content = '';

  /// 文件名
  @JsonProperty()
  String fileName = '';

  /// 摘要
  @JsonProperty()
  String abstract = '';
}

/// 文章数据基本要素
@jsonSerializable
mixin class PostDataBase {
  /// 标题
  @JsonProperty()
  String title = '';

  /// 日期
  @JsonProperty()
  String date = '';

  /// 封面图
  @JsonProperty()
  String feature = defaultPostFeaturePath;

  /// 隐藏
  @JsonProperty()
  bool hideInList = false;

  /// 置顶
  @JsonProperty()
  bool isTop = false;
}

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

/// 文章数据
@jsonSerializable
class PostData extends PostDataBase {
  /// 已发布
  @JsonProperty()
  bool published = false;

  /// 标签
  @JsonProperty()
  List<Tag> tags = [];
}

/// 文章
@jsonSerializable
class Post extends PostData with PostBase {}

/// 文章渲染数据
@jsonSerializable
class PostRender extends PostDataBase with PostBase {
  /// 描述
  @JsonProperty()
  String description = '';

  /// 日期格式化
  @JsonProperty()
  String dateFormat = '';

  /// 文章链接
  @JsonProperty()
  String link = '';

  /// 目录
  @JsonProperty()
  String toc = '';

  /// 统计数据
  @JsonProperty()
  Stats stats = Stats();

  /// 下一篇文章
  @JsonProperty()
  PostRender? nextPost;

  /// 上一篇文章
  @JsonProperty()
  PostRender? prevPost;

  /// 标签
  @JsonProperty()
  List<TagRender> tags = [];
}

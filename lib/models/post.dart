import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable, JsonProperty;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:glidea/models/tag.dart';

/// 文章基本要素
@jsonSerializable
mixin class PostBase {
  /// 内容
  @JsonProperty()
  String content = '';

  /// 文件名
  @JsonProperty()
  String fileName = Uid.v4;

  /// 摘要: 根据 [content] 中的摘要分隔符来生成的
  ///
  /// 摘要分隔符: \<!--\s\*more\s\*-->
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
  @JsonProperty(converterParams: {'format': defaultDateFormat})
  DateTime date = DateTime.now().setFormat(pattern: defaultDateFormat);

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
  /// 提示文本文本, 例如 2 min read
  @JsonProperty()
  String text = '';

  /// 分钟数
  @JsonProperty()
  int minutes = 0;

  /// 时间
  @JsonProperty()
  int time = 0;

  /// 文章字数
  @JsonProperty()
  int words = 0;
}

/// 文章数据
@jsonSerializable
class PostData extends PostDataBase {
  /// 已发布
  @JsonProperty()
  bool published = false;

  /// 标签的 slug 集合
  @JsonProperty()
  List<String> tags = [];
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

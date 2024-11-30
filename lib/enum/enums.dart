import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable;

/// 部署的平台
@jsonSerializable
enum DeployPlatform {
  github,
  coding,
  sftp,
  gitee,
  netlify,
}

/// 评论平台
@jsonSerializable
enum CommentPlatform {
  gitalk,
  disqus,
}

/// 代理方式
@jsonSerializable
enum ProxyWay {
  direct,
  proxy,
  none,
}

/// 内链后或者外链类型
@jsonSerializable
enum MenuTypes {
  internal,
  external,
}

@jsonSerializable
enum UrlFormats {
  slug,
  shortId,
}

/// 输入字段类型
@jsonSerializable
enum FieldType {
  input,
  select,
  textarea,
  radio,
  toggle,
  slider,
  picture,
  //markdown,
  array,
}

/// InputCard 的类型
@jsonSerializable
enum InputCardType {
  card,
  post,
  none,
}

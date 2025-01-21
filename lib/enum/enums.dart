import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_json_mapper/dart_json_mapper.dart' show jsonSerializable;
import 'package:flutter/material.dart' show Offset, Alignment;

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
  color,
  post,
  none,
}

/// 抽屉动画的方向
enum DrawerDirection {
  /// 淡入进来
  center(value: Offset.zero),
  rightToLeft(value: Offset(1.0, 0.0)),
  leftToRight(value: Offset(-1.0, 0.0)),
  bottomToTop(value: Offset(0.0, 1.0)),
  topToBottom(value: Offset(0.0, -1.0));

  const DrawerDirection({required this.value});

  /// Slide 动画开始的位置
  final Offset value;

  /// 是淡入
  bool get isFade => value.dx == 0.0 && value.dy == 0.0;

  /// 对齐
  Alignment get toAlign => Alignment(value.dx, value.dy);
}

/// action 类型
enum ActionType {
  create,
  update,
  delete,
}

extension EnumStringExt on String {
  T? toEnum<T extends Enum>(Iterable<T> values) {
    return values.firstWhereOrNull((t) => this == t.name);
  }
}

import 'package:flutter/material.dart';

class Constants {
  static const List<Map<String, String>> UrlFormats = [
    {
      'text': 'Slug',
      'value': 'SLUG',
    },
    {
      'text': 'Short ID',
      'value': 'SHORT_ID',
    },
  ];

  static const int defaultPostPageSize = 10;

  static const int defaultArchivesPageSize = 50;

  static const int defaultFeedCount = 10;

  static const String defaultArchivesPath = 'archives';

  static const String defaultPostPath = 'post';

  static const String defaultTagPath = 'tag';

  static const String defaultPostFeaturePath = '/post-images/post-feature.jpg';

  static const String defaultRobotsPath = 'User-agent: *\nDisallow:';
}

const InputDecoration kInputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  hoverColor: Colors.transparent, // 悬停时的背景色
);

const EdgeInsetsGeometry kHorizontalPadding = EdgeInsets.symmetric(vertical: 0, horizontal: 12);

const EdgeInsetsGeometry kLabelPadding = EdgeInsets.only(right: 16);

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

  static const String defaultRobotsPath = 'User-agent: *\nDisallow:';
}

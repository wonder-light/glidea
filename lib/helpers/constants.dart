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

  static const int DEFAULT_POST_PAGE_SIZE = 10;

  static const int DEFAULT_ARCHIVES_PAGE_SIZE = 50;

  static const int DEFAULT_FEED_COUNT = 10;

  static const String DEFAULT_ARCHIVES_PATH = 'archives';

  static const String DEFAULT_POST_PATH = 'post';

  static const String DEFAULT_TAG_PATH = 'tag';

  static const String DEFAULT_ROBOTS_TEXT = 'User-agent: *\nDisallow:';
}

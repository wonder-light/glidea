import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetPage;
import 'package:glidea/views/articles.dart';
import 'package:glidea/views/home.dart';
import 'package:glidea/views/loading.dart';
import 'package:glidea/views/menu.dart';
import 'package:glidea/views/notfound.dart';
import 'package:glidea/views/remote.dart';
import 'package:glidea/views/setting.dart';
import 'package:glidea/views/tags.dart';
import 'package:glidea/views/theme.dart';

class AppRouter {
  /// 首页路由路径
  static const String home = '/';
  static const String articles = '/articles';
  static const String menu = '/menu';
  static const String tags = '/tags';
  static const String theme = '/theme';
  static const String remote = '/remote';
  static const String setting = '/setting';
  static const String loading = '/loading';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.home,
      title: 'main',
      page: () => const HomeWidget(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      children: [
        GetPage(name: articles, page: () => const ArticlesWidget(), preventDuplicates: true),
        GetPage(name: menu, page: () => const MenuWidget(), preventDuplicates: true),
        GetPage(name: tags, page: () => const TagsWidget(), preventDuplicates: true),
        GetPage(name: theme, page: () => const ThemeWidget(), preventDuplicates: true),
        GetPage(name: remote, page: () => const RemoteWidget(), preventDuplicates: true),
        GetPage(name: setting, page: () => const SettingWidget(), preventDuplicates: true), // 移动端才有设置页面
        GetPage(name: loading, page: () => const LoadingWidget(), preventDuplicates: true),
      ],
    ),
    GetPage(name: '/*', page: () => const NotfoundWidget(), preventDuplicates: true),
  ];
}

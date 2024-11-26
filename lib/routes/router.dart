import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetPage;
import 'package:glidea/views/articles.dart';
import 'package:glidea/views/home.dart';
import 'package:glidea/views/loading.dart';
import 'package:glidea/views/menu.dart';
import 'package:glidea/views/setting.dart';
import 'package:glidea/views/tags.dart';
import 'package:glidea/views/theme.dart';
import 'package:glidea/views/notfound.dart';
import 'package:glidea/views/remote.dart';

class AppRouter {
  /// 首页路由路径
  static const String home = '/';

  /// 文章路由路径
  static const String article = '/articles';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.home,
      title: 'main',
      page: () => const HomeWidget(),
      participatesInRootNavigator: true,
      preventDuplicates: true,
      children: [
        GetPage(name: '/articles', title: 'articles', page: () => const ArticlesWidget(), preventDuplicates: true),
        GetPage(name: '/menu', title: 'menu', page: () => const MenuWidget(), preventDuplicates: true),
        GetPage(name: '/tags', title: 'tags', page: () => const TagsWidget(), preventDuplicates: true),
        GetPage(name: '/theme', title: 'theme', page: () => const ThemeWidget(), preventDuplicates: true),
        GetPage(name: '/remote', title: 'remote', page: () => const RemoteWidget(), preventDuplicates: true),
        GetPage(name: '/setting', title: 'remote', page: () => const SettingWidget(), preventDuplicates: true), // 移动端才有设置页面
        GetPage(name: '/loading', title: 'loading', page: () => const LoadingWidget(), preventDuplicates: true),
      ],
    ),
    GetPage(name: '/*', page: () => const NotfoundWidget(), preventDuplicates: true),
  ];
}

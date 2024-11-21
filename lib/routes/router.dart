import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetPage;
import 'package:glidea/routes/bindings.dart';
import 'package:glidea/views/Articles.dart';
import 'package:glidea/views/Home.dart';
import 'package:glidea/views/Loading.dart';
import 'package:glidea/views/Menu.dart';
import 'package:glidea/views/Setting.dart';
import 'package:glidea/views/Tags.dart';
import 'package:glidea/views/Theme.dart';
import 'package:glidea/views/notfound.dart';

class AppRouter {
  /// 首页路由路径
  static const String homeRoute = '/';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.homeRoute,
      title: 'main',
      page: () => const HomeWidget(),
      children: [
        GetPage(name: '/articles', title: 'articles', page: () => const ArticlesWidget()),
        GetPage(name: '/menu', title: 'menu', page: () => const MenuWidget()),
        GetPage(name: '/tags', title: 'tags', page: () => const TagsWidget()),
        GetPage(name: '/theme', title: 'theme', page: () => const ThemeWidget()),
        GetPage(name: '/setting', title: 'setting', page: () => const SettingWidget()),
        GetPage(name: '/loading', title: 'loading', page: () => const LoadingWidget()),
      ],
    ),
    GetPage(name: '/*', page: () => const NotfoundWidget()),
  ];
}

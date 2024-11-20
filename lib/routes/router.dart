import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glidea/routes/bindings.dart';

class AppRouter {
  /// 首页路由路径
  static const String homeRoute = '/';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.homeRoute,
      title: 'main',
      page: () => const Home(),
      binding: SiteBind(),
      children: [
        GetPage(name: '/articles', title: 'articles', page: () => const Articles()),
        GetPage(name: '/menu', title: 'menu', page: () => const Menu()),
        GetPage(name: '/tags', title: 'tags', page: () => const Tags()),
        GetPage(name: '/theme', title: 'theme', page: () => const Theme()),
        GetPage(name: '/setting', title: 'setting', page: () => const Setting()),
        GetPage(name: '/loading', title: 'loading', page: () => const Loading()),
      ],
      unknownRoute: GetPage(name: '*', page: () => const articles()),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppRouter {
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: '/',
      title: 'main',
      page: () => const Home(),
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


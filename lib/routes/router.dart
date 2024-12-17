import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetPage;
import 'package:glidea/components/setting/setting_editor.dart';
import 'package:glidea/views/articles.dart';
import 'package:glidea/views/home.dart';
import 'package:glidea/views/menu.dart';
import 'package:glidea/views/notfound.dart';
import 'package:glidea/views/post.dart';
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
  static const String tabletSetting = '/tabletSetting';
  static const String phoneSetting = '/phoneSetting';
  static const String post = '/post';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.home,
      title: 'main',
      page: () => const HomeView(),
      participatesInRootNavigator: true,
      children: [
        GetPage(name: articles, page: () => const ArticlesView()),
        GetPage(name: menu, page: () => const MenuView()),
        GetPage(name: tags, page: () => const TagsView()),
        GetPage(name: theme, page: () => const ThemeView()),
        GetPage(name: remote, page: () => const RemoteView()),
        // 平板端才有设置页面
        GetPage(name: tabletSetting, page: () => const SettingEditor(isVertical: false)),
        // 移动端才有设置页面
        GetPage(name: phoneSetting, page: () => const SettingView()),
        // post 页面
        GetPage(name: post, page: () => const PostView(), participatesInRootNavigator: true),
        GetPage(name: '/*', page: () => const NotfoundWidget(), participatesInRootNavigator: true),
      ],
    ),
  ];
}

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
  static const String post = '/post';
  static const String tabletSetting = '/tabletSetting';
  static const String phoneSetting = '/phoneSetting';
  static const String phoneTheme = '/phoneTheme';
  static const String phoneRemote = '/phoneRemote';

  /// 路由路线集合
  static final List<GetPage<Widget>> routes = [
    GetPage(
      name: AppRouter.home,
      title: 'main',
      page: () => const HomeView(),
      participatesInRootNavigator: true,
      children: [
        GetPage(name: articles, page: buildArticles),
        GetPage(name: menu, page: buildMenu),
        GetPage(name: tags, page: buildTags),
        GetPage(name: theme, page: buildTheme),
        GetPage(name: remote, page: buildRemote),
        // 平板端才有设置页面
        GetPage(name: tabletSetting, page: buildTabletSetting),
        // 移动端才有设置页面
        GetPage(name: phoneSetting, page: buildPhoneSetting),
        GetPage(name: phoneTheme, page: buildTheme, participatesInRootNavigator: true),
        GetPage(name: phoneRemote, page: buildRemote, participatesInRootNavigator: true),
        // post 页面
        GetPage(name: post, page: buildPost, participatesInRootNavigator: true),
        GetPage(name: '/*', page: buildNotfound, participatesInRootNavigator: true),
      ],
    ),
  ];

  static Widget buildArticles() => const ArticlesView();

  static Widget buildMenu() => const MenuView();

  static Widget buildTags() => const TagsView();

  static Widget buildTheme() => const ThemeView();

  static Widget buildRemote() => const RemoteView();

  static Widget buildPost() => const PostView();

  static Widget buildNotfound() => const NotfoundWidget();

  static Widget buildTabletSetting() => const SettingEditor(isVertical: false);

  static Widget buildPhoneSetting() => const SettingView();
}

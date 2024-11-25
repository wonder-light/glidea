﻿import 'package:get/get.dart' show FirstWhereOrNullExt, StateController;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';

/// 混合 - 菜单
mixin MenuSite on StateController<Application> {
  /// 菜单
  List<Menu> get menus => state.menus;

  /// 创建菜单
  Menu createMenu() => Menu();

  /// 更新菜单
  void updateMenu({required Menu newMenu, Menu? oldMenu}) {
    oldMenu = state.menus.firstWhereOrNull((m) => m == oldMenu);
    if (oldMenu == null) {
      // 添加标签
      state.menus.add(newMenu);
    } else {
      // 更新
      oldMenu.name = newMenu.name;
      oldMenu.openType = newMenu.openType;
      oldMenu.link = newMenu.link;
    }
    refresh();
  }

  /// 删除新标签
  void removeMenu(Menu menu) {
    if (state.menus.remove(menu)) {
      refresh();
      // TODO: 保存菜单
    }
  }

  /// 获取可以引用的链接
  List<TLinkData> getReferenceLink() {
    // 可以引用的链接
    var links = state.menus.map<TLinkData>((m) => (name: m.name, link: m.link)).toList();
    // 含有 post 文章的链接
    var postMenus = links.where((t) => t.link.contains('/${Constants.defaultPostPath}/')).toList();
    // 冲 posts 中去除含有 postMenus 的文章
    var posts = state.posts
        .map<TLinkData>((p) => (name: p.title, link: '/${Constants.defaultPostPath}/${p.fileName}'))
        .where((p) => !postMenus.any((t) => t.link == p.link))
        .toList();
    // 合并
    links.addAll(posts);
    return links;
  }
}

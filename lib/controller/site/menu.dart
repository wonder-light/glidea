part of 'site.dart';

/// 混合 - 菜单
mixin MenuSite on DataProcess {
  /// 菜单
  List<Menu> get menus => state.menus;

  /// 创建菜单
  Menu createMenu() => Menu();

  /// 更新菜单
  ///
  /// 返回值是 true 就是更新成功, 否则就是更新失败
  Future<bool> updateMenu({required Menu newData, Menu? oldData}) async {
    try {
      final index = oldData == null ? -1 : state.menus.indexOf(oldData);
      // oldData 在 menus 中存在
      if (index >= 0) {
        state.menus[index] = newData;
      } else {
        // 添加标签
        state.menus.add(newData);
      }
      await saveSiteData();
      return true;
    } catch (e, s) {
      Log.e('update or add menu failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 删除新标签
  ///
  /// 返回值是 true 就是删除成功, 否则就是删除失败
  Future<bool> removeMenu(Menu menu) async {
    try {
      if (!state.menus.remove(menu)) {
        return false;
      }
      await saveSiteData();
      return true;
    } catch (e, s) {
      Log.e('delete menu failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 获取可以引用的链接
  List<TLinkData> getReferenceLink() {
    final postPath = '/${state.themeConfig.postPath}/';
    return [
      for (var menu in state.menus)
        if (!menu.link.startsWith(postPath))
          // 筛选出不包含 post 的链接
          (name: menu.name, link: menu.link),
      for (var post in state.posts)
        // posts 的链接
        (name: post.title, link: '$postPath${post.fileName}'),
    ];
  }
}

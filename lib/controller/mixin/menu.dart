import 'package:collection/collection.dart' show IterableExtension;
import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/helpers/get.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';

import 'data.dart';

/// 混合 - 菜单
mixin MenuSite on StateController<Application>, DataProcess {
  /// 菜单
  List<Menu> get menus => state.menus;

  /// 创建菜单
  Menu createMenu() => Menu();

  /// 更新菜单
  void updateMenu({required Menu newData, Menu? oldData}) async {
    oldData = state.menus.firstWhereOrNull((m) => m == oldData);
    if (oldData == null) {
      // 添加标签
      state.menus.add(newData);
    } else {
      // 更新
      oldData.name = newData.name;
      oldData.openType = newData.openType;
      oldData.link = newData.link;
    }
    try {
      await saveSiteData();
      Get.success(Tran.menuSuccess);
    } catch (e) {
      Get.error(Tran.saveError);
    }
  }

  /// 删除新标签
  void removeMenu(Menu menu) async {
    if (!state.menus.remove(menu)) {
      Get.error(Tran.menuDeleteFailure);
      return;
    }
    try {
      await saveSiteData();
      Get.success(Tran.menuDelete);
    } catch (e) {
      Get.error(Tran.menuDeleteFailure);
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

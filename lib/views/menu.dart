import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/components/menu/menu_editor.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/models/menu.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        IconButton(
          onPressed: addNewMenu,
          icon: const Icon(PhosphorIconsRegular.plus),
          tooltip: 'newMenu'.tr,
        ),
      ],
      child: Obx(
        () => ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return _buildMenuItem(site.menus[index]);
          },
          itemCount: site.menus.length,
          separatorBuilder: (BuildContext context, int index) {
            return Container(height: listSeparated);
          },
        ),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(Menu menu) {
    // 配色方案
    final colors = Get.theme.colorScheme;

    return ListItem(
      shape: ContinuousRectangleBorder(
        side: BorderSide(
          color: colors.onSurface,
          width: 0.15,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      constraints: const BoxConstraints(minHeight: 80),
      contentPadding: kVerPadding8 + kHorPadding16,
      leadingMargin: kRightPadding16,
      leading: const Icon(PhosphorIconsRegular.starFour),
      title: Text(menu.name),
      subtitle: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border.all(
                color: colors.outlineVariant,
                width: 0.4,
              ),
            ),
            child: Padding(
              padding: kHorPadding8,
              child: Text(menu.openType.name.tr),
            ),
          ),
          Container(padding: kRightPadding16),
          Text(menu.link),
        ],
      ),
      trailing: IconButton(
        onPressed: () => deleteMenu(menu),
        icon: const Icon(PhosphorIconsRegular.trash),
      ),
      onTap: () => editorMenu(menu),
    );
  }

  /// 添加新菜单
  void addNewMenu() {
    editorMenu(site.createMenu());
  }

  /// 编辑菜单
  void editorMenu(Menu menu) {
    /// 抽屉控制器
    final drawerController = DraController();

    Get.showDrawer(
      controller: drawerController,
      builder: (context) => MenuEditor(
        entity: menu,
        controller: drawerController,
        onSave: (data) {
          site.updateMenu(newData: data, oldData: menu);
        },
      ),
    );
  }

  /// 删除菜单
  void deleteMenu(Menu menu) {
    // 弹窗
    Get.dialog(DialogWidget(
      onCancel: () {
        Get.backLegacy();
      },
      onConfirm: () {
        site.removeMenu(menu);
        Get.backLegacy();
      },
    ));
  }
}

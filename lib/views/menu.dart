import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/ListItem.dart';
import 'package:glidea/components/dialog.dart';
import 'package:glidea/components/drawer.dart';
import 'package:glidea/components/menu/menuEditor.dart';
import 'package:glidea/components/pageAction.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/models/menu.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  /// 站点控制器
  final siteController = Get.find<SiteController>(tag: SiteController.tag);

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        IconButton(
          onPressed: addNewMenu,
          icon: const Icon(PhosphorIconsRegular.plus),
          tooltip: 'newTag'.tr,
        ),
      ],
      child: Obx(
        () => ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return _buildMenuItem(siteController.menus[index]);
          },
          itemCount: siteController.menus.length,
          separatorBuilder: (BuildContext context, int index) {
            return Container(height: 10);
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
      leadingMargin: const EdgeInsets.only(right: 18, left: 12),
      leading: const Icon(PhosphorIconsRegular.starFour),
      title: Text(
        menu.name,
        textScaler: const TextScaler.linear(1.2),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border.all(
                color: colors.outlineVariant,
                width: 0.4,
              ),
            ),
            child: Text(menu.openType.name),
          ),
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
    editorMenu(siteController.createMenu());
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
          siteController.updateMenu(newData: data, oldData: menu);
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
        siteController.removeMenu(menu);
        Get.backLegacy();
      },
    ));
  }
}

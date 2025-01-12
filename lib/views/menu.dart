import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/menu/menu_editor.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
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

  // 配色方案
  final colors = Get.theme.colorScheme;
  final textTheme = Get.theme.textTheme;

  // 形状
  late final shapeBorder = ContinuousRectangleBorder(
    side: BorderSide(
      color: colors.onSurface,
      width: 0.15,
    ),
    borderRadius: BorderRadius.circular(10.0),
  );

  /// 子标题样式
  late final subtitleTextStyle = textTheme.bodySmall?.copyWith(color: colors.outline);

  /// 装饰器
  late final decoration = BoxDecoration(
    color: colors.surfaceContainerLow,
    border: Border.all(
      color: colors.outlineVariant,
      width: 0.4,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        TipWidget.down(
          message: Tran.newMenu.tr,
          child: IconButton(
            onPressed: addNewMenu,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ),
      ],
      child: Obx(
        () => ListView.separated(
          itemBuilder: _buildMenuItem,
          itemCount: site.menus.length,
          separatorBuilder: (BuildContext context, int index) {
            return Container(height: listSeparated);
          },
        ),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(BuildContext context, int index) {
    final menu = site.menus[index];
    // 菜单项目
    return ListItem(
      shape: shapeBorder,
      constraints: const BoxConstraints(maxHeight: 80),
      contentPadding: kVerPadding8 + kHorPadding16,
      leadingMargin: kRightPadding16,
      leading: const Icon(PhosphorIconsRegular.starFour),
      title: Text(menu.name),
      subtitle: Row(
        children: [
          DecoratedBox(
            decoration: decoration,
            child: Padding(
              padding: kHorPadding8,
              child: Text(menu.openType.name.tr),
            ),
          ),
          Container(padding: kRightPadding16),
          Text(menu.link),
        ],
      ),
      subtitleTextStyle: subtitleTextStyle,
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
    final isPhone = Get.isPhone;
    Get.showDrawer(
      direction: isPhone ? DrawerDirection.center : DrawerDirection.rightToLeft,
      stepHeight: isPhone ? 20 : null,
      builder: (context) => MenuEditor(
        entity: menu,
        onSave: (data) async {
          final value = await site.updateMenu(newData: data, oldData: menu);
          value ? Get.success(Tran.menuSuccess) : Get.error(Tran.saveError);
        },
      ),
    );
  }

  /// 删除菜单
  void deleteMenu(Menu menu) {
    // 弹窗
    Get.dialog(DialogWidget(
      onCancel: () => Get.backLegacy(),
      onConfirm: () async {
        final value = await site.removeMenu(menu);
        value ? Get.success(Tran.menuDelete) : Get.error(Tran.menuDeleteFailure);
        site.removeMenu(menu);
        Get.backLegacy();
      },
    ));
  }
}

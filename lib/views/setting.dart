import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 菜单数据
  final List<TRouterData> menus = [
    (name: Tran.themeSetting, route: AppRouter.phoneTheme, icon: PhosphorIconsRegular.tShirt),
    (name: Tran.customConfig, route: AppRouter.phoneTheme, icon: PhosphorIconsRegular.hoodie),
    (name: Tran.remoteSetting, route: AppRouter.phoneRemote, icon: PhosphorIconsRegular.hardDrives),
    (name: Tran.commentSetting, route: AppRouter.phoneRemote, icon: PhosphorIconsRegular.chatCenteredDots),
    (name: Tran.otherSetting, route: AppRouter.phoneOtherSetting, icon: PhosphorIconsRegular.slidersHorizontal),
  ];

  /// 包括内边距的高度
  final itemHeight = 68.0;

  /// 内边距
  final padding = kVerPadding4 + kHorPadding12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tran.setting.tr),
      ),
      body: ListView.builder(
        itemExtent: itemHeight,
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          final item = menus[index];
          return Padding(
            padding: padding,
            child: ListItem(
              onTap: () => toRouter(item.route, arguments: item.name),
              leading: Icon(item.icon),
              title: Text(item.name.tr),
              //constraints: const BoxConstraints.expand(height: itemHeight - 8),
              contentPadding: kHorPadding16,
              dense: true,
            ),
          );
        },
      ),
    );
  }

  /// 转到路由
  void toRouter(String name, {dynamic arguments}) {
    Get.toNamed(name, arguments: arguments);
  }
}

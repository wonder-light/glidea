import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/controller/site.dart';
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
    (name: Tran.theme, route: AppRouter.phoneTheme, icon: PhosphorIconsRegular.tShirt),
    (name: Tran.customConfig, route: AppRouter.phoneTheme, icon: PhosphorIconsRegular.hoodie),
    (name: Tran.remote, route: AppRouter.phoneRemote, icon: PhosphorIconsRegular.hardDrives),
    (name: Tran.commentSetting, route: AppRouter.phoneRemote, icon: PhosphorIconsRegular.chatCenteredDots),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tran.setting.tr),
      ),
      body: ListView.builder(
        itemExtent: 68,
        itemCount: menus.length,
        itemBuilder: (BuildContext context, int index) {
          //const itemHeight = 60.0;
          final item = menus[index];
          return Padding(
            padding: kVerPadding4 + kHorPadding12,
            child: ListItem(
              onTap: () => toRouter(item.route, arguments: item.name),
              leading: Icon(item.icon),
              title: Text(item.name.tr),
              //constraints: const BoxConstraints.expand(height: itemHeight),
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

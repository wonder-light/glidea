import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class HomeUpPanel extends StatefulWidget {
  const HomeUpPanel({super.key});

  @override
  State<StatefulWidget> createState() => _HomeUpPanelState();
}

class _HomeUpPanelState extends State<HomeUpPanel> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 菜单数据
  final List<TRouterData> menus = [
    (name: Tran.article, route: AppRouter.articles, icon: PhosphorIconsRegular.article),
    (name: Tran.menu, route: AppRouter.menu, icon: PhosphorIconsRegular.list),
    (name: Tran.tag, route: AppRouter.tags, icon: PhosphorIconsRegular.tag),
    (name: Tran.theme, route: AppRouter.theme, icon: PhosphorIconsRegular.tShirt),
    (name: Tran.remote, route: AppRouter.remote, icon: PhosphorIconsRegular.hardDrives),
  ];

  /// 桌面端的当前路由索引
  final currentRouter = AppRouter.articles.obs;

  /// 数据的数量
  late final dataNum = {
    Tran.article: site.posts.length,
    Tran.menu: site.menus.length,
    Tran.tag: site.tags.length,
  };

  final theme = Theme.of(Get.context!);

  @override
  void initState() {
    super.initState();
    addTabletMenu();
    final routeName = Get.rootController.rootDelegate.pageSettings?.name;
    if (!menus.any((m) => m.name == routeName)) {
      toName(AppRouter.articles);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Get.isDesktop && menus.length > 5) {
      menus.removeLast();
    }
    addTabletMenu();
  }

  @override
  void dispose() {
    currentRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 头像
    Widget childWidget = Container(
      alignment: Alignment.center,
      color: theme.scaffoldBackgroundColor,
      padding: kVerPadding16 * 1.6 + kTopPadding8,
      child: const ClipOval(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: kLogSize,
          height: kLogSize,
        ),
      ),
    );
    // 项目
    List<Widget> children = [for (var item in menus) _buildItem(item)];
    // 插入
    children.insert(0, childWidget);
    // 放到一个列表中
    childWidget = Column(
      spacing: kTopPadding8.top,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    // 平板端使用滚动, [IntrinsicWidth] 与 [CustomScrollView] 不能同时使用
    if (!Get.isDesktop) {
      childWidget = SingleChildScrollView(child: childWidget);
    }
    // 包裹水平边距
    return Padding(padding: kHorPadding12, child: childWidget);
  }

  Widget _buildItem(TRouterData item) {
    // 菜单列表高度
    const itemHeight = 50.0;
    final colorScheme = theme.colorScheme;
    return Obx(
      () => ListItem(
        onTap: () => toName(item.route),
        leading: Icon(item.icon),
        title: Text(item.name.tr),
        trailing: Text('${dataNum[item.name] ?? ''}'),
        constraints: const BoxConstraints.expand(height: itemHeight),
        selected: currentRouter.value == item.route,
        selectedColor: colorScheme.surfaceContainerLow,
        selectedTileColor: colorScheme.primary,
        contentPadding: kHorPadding16,
        dense: true,
      ),
    );
  }

  /// 添加平板端的菜单
  void addTabletMenu() {
    // 平板端
    if (Get.isTablet && menus.length == 5) {
      menus.add((name: Tran.setting, route: AppRouter.tabletSetting, icon: PhosphorIconsRegular.slidersHorizontal));
    }
  }

  /// 转到 route
  void toName(String route) {
    currentRouter.value = route;
    Get.toNamed(route);
  }
}

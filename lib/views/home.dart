import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, GetPage, GetRouterOutlet, Inst, IntExtension, Obx, Trans;
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/home/down_panel.dart';
import 'package:glidea/components/home/up_panel.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/windows.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/library/worker/worker.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends LifecycleState<HomeView> {
  /// 移动端的当前路由索引
  var mobileIndex = 0.obs;

  /// 当前显示的路由
  var showRouter = AppRouter.articles;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 移动端的底部导航栏菜单
  final List<TRouterData> mobileMenus = [
    (name: Tran.article, route: AppRouter.articles, icon: PhosphorIconsRegular.article),
    (name: Tran.menu, route: AppRouter.menu, icon: PhosphorIconsRegular.list),
    (name: Tran.tag, route: AppRouter.tags, icon: PhosphorIconsRegular.tag),
    (name: Tran.setting, route: AppRouter.phoneSetting, icon: PhosphorIconsRegular.slidersHorizontal),
  ];

  @override
  void dispose() {
    site.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await onAppHide();
    Background.instance.exit();
    print('---------------onWindowClose----------------');
  }

  @override
  Future<void> onAppHide() async {
    if (!site.isDisposed) {
      try {
        await site.saveSiteData();
      } catch (e, s) {
        Log.e('failed to save data while APP is hidden', error: e, stackTrace: s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.responsive = ResponsiveBreakpoints.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: site.initTask.future,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: LoadingWidget());
            }
            if (Get.isPhone) {
              return _buildBody();
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftPanel(),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }

  /// 构建左边面板
  Widget _buildLeftPanel() {
    // 使用 [IntrinsicWidth] 限制最大宽度, 并用 [ConstrainedBox] 限制最小宽度
    return IntrinsicWidth(
      stepWidth: 40,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: kPanelWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeUpPanel(),
            if (Get.isDesktop) const HomeDownPanel(),
          ],
        ),
      ),
    );
  }

  /// 构建移动端的底部导航栏
  Widget? _buildMobileBottomNav() {
    if (!Get.isPhone) {
      return null;
    }
    // 当前路由路径
    final routeName = Get.rootController.rootDelegate.pageSettings?.name;
    if (mobileMenus[mobileIndex.value].route != routeName) {
      toRouter(mobileIndex.value);
    }
    return Obx(
      () => BottomNavigationBar(
        items: [
          for (var item in mobileMenus)
            BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.name.tr,
            ),
        ],
        currentIndex: mobileIndex.value,
        onTap: toRouter,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }

  // 构建主体路由
  Widget _buildBody() {
    return GetRouterOutlet(
      initialRoute: AppRouter.articles,
      anchorRoute: AppRouter.home,
      filterPages: filterPages,
    );
  }

  /// 过滤页面
  Iterable<GetPage> filterPages(Iterable<GetPage> afterAnchor) {
    if (afterAnchor.isNotEmpty) {
      return afterAnchor.take(1);
    }
    return [];
  }

  /// 转到路由
  void toRouter(int index) {
    mobileIndex.value = index;
    Get.toNamed(mobileMenus[index].route);
  }
}

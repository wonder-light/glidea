﻿import 'dart:math' show pi;
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, GetPage, GetRouterOutlet, Inst, IntExtension, DoubleExtension, Obx, StateExt, StringExtension, Trans;
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/setting/setting_editor.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/routes/router.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints, ResponsiveBreakpointsData;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// 关于当前屏幕的响应性数据
  late ResponsiveBreakpointsData breakpoints;

  /// 侦听器，可用于侦听应用程序生命周期中的更改
  late final AppLifecycleListener lifecycle;

  /// 桌面端的当前路由索引
  var desktopRouter = AppRouter.articles.obs;

  /// 移动端的当前路由索引
  var mobileIndex = 0.obs;

  /// 同步图标的旋转角度
  var syncIconTurns = 0.0.obs;

  /// 当前显示的路由
  var showRouter = AppRouter.articles;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 菜单数据
  final List<TRouterData> menus = [
    (name: 'article', route: AppRouter.articles, icon: PhosphorIconsRegular.article),
    (name: 'menu', route: AppRouter.menu, icon: PhosphorIconsRegular.list),
    (name: 'tag', route: AppRouter.tags, icon: PhosphorIconsRegular.tag),
    (name: 'theme', route: AppRouter.theme, icon: PhosphorIconsRegular.tShirt),
    (name: 'remote', route: AppRouter.remote, icon: PhosphorIconsRegular.hardDrives),
  ];

  /// 移动端的底部导航栏菜单
  final List<TRouterData> mobileMenus = [];

  /// 预览和发布
  final List<TActionData> actions = [];

  @override
  void initState() {
    super.initState();
    // 预览和发布两个操作按钮
    actions.add((name: 'preview', call: preview, icon: PhosphorIconsRegular.eye));
    actions.add((name: 'publishSite', call: publish, icon: PhosphorIconsRegular.cloudArrowUp));
    // 下面一行的按钮
    actions.add((name: 'setting', call: openSetting, icon: PhosphorIconsRegular.slidersHorizontal));
    actions.add((name: 'visitSite', call: openWebSite, icon: PhosphorIconsRegular.globe));
    actions.add((name: 'starSupport', call: starSupport, icon: PhosphorIconsRegular.githubLogo));

    mobileMenus.addAll(menus.take(3));
    mobileMenus.add((name: 'setting', route: AppRouter.setting, icon: PhosphorIconsRegular.slidersHorizontal));

    lifecycle = AppLifecycleListener(onStateChange: handleStateChange, onExitRequested: handleExitRequested);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取匹配的路由
    final route = Get.isDesktop ? desktopRouter.value : mobileMenus[mobileIndex.value].route;
    // 路由不相同时更新路由
    if (showRouter != route) {
      toRouter(route);
    }
  }

  @override
  void dispose() {
    site.dispose();
    lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取断点数据
    breakpoints = ResponsiveBreakpoints.of(context);
    // 构建控件
    return Scaffold(
      body: SafeArea(
        child: site.obx(
          (data) => breakpoints.isDesktop
              ? Row(
                  children: [
                    _buildLeftPanel(),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: _buildBody()),
                  ],
                )
              : _buildBody(),
          onLoading: const Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoadingWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }

  /// 构建左边面板
  Widget _buildLeftPanel() {
    var colorScheme = Get.theme.colorScheme;
    // 头像
    Widget childWidget = Container(
      alignment: Alignment.center,
      padding: kVerPadding16 + kTopPadding16,
      child: const ClipOval(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: kLogSize,
          height: kLogSize,
        ),
      ),
    );
    // 菜单列表
    List<Widget> widgets = [
      // 菜单列表
      for (var item in menus)
        Padding(
          padding: kVerPadding4 + kHorPadding12,
          child: ListItem(
            onTap: () {
              desktopRouter.value = item.route;
              toRouter(item.route);
            },
            leading: Icon(item.icon),
            title: Text(item.name.tr),
            trailing: Text(site.getHomeLeftPanelNum(item.name)),
            constraints: const BoxConstraints(maxHeight: 50),
            selected: desktopRouter.value == item.route,
            selectedColor: colorScheme.surfaceContainerLow,
            selectedTileColor: colorScheme.primary,
            contentPadding: kHorPadding16,
            dense: true,
          ),
        ),
    ];
    // 在第一个的位置插入头像
    widgets.insert(0, childWidget);
    // 插入一个空白, 进行填充中间的间隔
    widgets.add(Expanded(child: Container()));
    // 最底部的按钮
    childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var item in actions.skip(2))
          IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.comfortable,
            onPressed: item.call,
            icon: Icon(item.icon),
            tooltip: item.name.tr,
          ),
      ],
    );
    // 加上预览和发布按钮
    childWidget = Padding(
      padding: kVer8Hor32,
      child: Column(
        children: [
          _buildActionButton(actions[0]),
          _buildActionButton(actions[1], isFilled: true),
          childWidget,
        ],
      ),
    );
    widgets.add(childWidget);
    // 放到列中
    childWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
    // 使用 [IntrinsicWidth] 限制最大宽度, 并用 [ConstrainedBox] 限制最小宽度
    return IntrinsicWidth(
      stepWidth: 40,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kPanelWidth,
        ),
        child: childWidget,
      ),
    );
  }

  Widget _buildActionButton(TActionData item, {bool isFilled = false}) {
    // 按钮样式
    ButtonStyle style = ButtonStyle(padding: WidgetStatePropertyAll(kAllPadding16 / 2));
    // 内容
    Widget contentWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon),
        const Padding(padding: kRightPadding8),
        Text(item.name.tr),
      ],
    );
    // 包裹的按钮
    late Widget childWidget;
    if (isFilled) {
      childWidget = FilledButton(
        onPressed: item.call,
        style: style,
        child: Obx(() {
          if (!site.inBeingSync.value) {
            return contentWidget;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: syncIconTurns.value,
                duration: const Duration(seconds: 2),
                onEnd: updateSyncRotate,
                child: const Icon(PhosphorIconsRegular.arrowsClockwise),
              )
            ],
          );
        }),
      );
    } else {
      childWidget = OutlinedButton(
        onPressed: item.call,
        style: style,
        child: contentWidget,
      );
    }
    // 加上边距
    return Padding(
      padding: kVerPadding8,
      // 包裹的按钮
      child: childWidget,
    );
  }

  /// 构建移动端的底部导航栏
  Widget? _buildMobileBottomNav() {
    if (breakpoints.isDesktop) {
      return null;
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
        onTap: (index) {
          mobileIndex.value = index;
          toRouter(mobileMenus[index].route, mobile: true);
        },
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

  /// 应用程序生命周期更改时的回调
  void handleStateChange(AppLifecycleState state) {}

  /// 一个回调，用于询问应用程序是否允许在退出可以取消的情况下退出应用程序
  Future<AppExitResponse> handleExitRequested() async {
    if (!site.isDisposed) {
      await site.saveSiteData();
    }
    Log.e('onExitRequested');
    return AppExitResponse.exit;
  }

  /// 过滤页面
  Iterable<GetPage> filterPages(Iterable<GetPage> afterAnchor) {
    if (afterAnchor.isNotEmpty) {
      return afterAnchor.take(1);
    }
    return [];
  }

  /// 预览网页
  void preview() {
    site.previewSite();
  }

  /// 发布网页
  void publish() async {
    site.inBeingSync.removeListener(updateSyncRotate);
    site.inBeingSync.addListener(updateSyncRotate);
    site.publishSite();
  }

  /// 更新旋转角度
  void updateSyncRotate() {
    // 下一帧调用
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => syncIconTurns.value += pi);
  }

  /// 打开设置
  void openSetting() {
    /// 抽屉控制器
    final drawerController = DraController();
    // 显示抽屉
    Get.showDrawer(
      stepWidth: double.infinity,
      stepHeight: double.infinity,
      direction: DrawerDirection.bottomToTop,
      controller: drawerController,
      builder: (ctx) => SettingEditor(
        entity: 12,
        controller: drawerController,
      ),
    );
  }

  /// 打开发布在网站
  void openWebSite() async {
    var domain = site.domain;
    if (domain.isEmpty) {
      Log.i('当前网址的空的，无法打开哦！');
      return;
    }
    final success = await launchUrlString(domain);
    if (!success) {
      Log.i('网站打开失败 $domain');
    }
  }

  /// 给个 start 支持
  void starSupport() async {
    final success = await launchUrlString('https://github.com/wonder-light/glidea');
    if (!success) {
      Log.i('github 打开失败');
    }
  }

  /// 转到路由
  void toRouter(String name, {bool mobile = false}) {
    showRouter = name;
    Get.toNamed(name);
  }
}

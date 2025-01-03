﻿import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, GetPage, GetRouterOutlet, Inst, IntExtension, Obx, StateExt, StringExtension, Trans;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/setting/setting_editor.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;
import 'package:window_manager/window_manager.dart' show WindowListener;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WindowListener {
  /// 侦听器，可用于侦听应用程序生命周期中的更改
  late final AppLifecycleListener lifecycle;

  /// 桌面端的当前路由索引
  var desktopRouter = AppRouter.articles.obs;

  /// 移动端的当前路由索引
  var mobileIndex = 0.obs;

  /// 当前显示的路由
  var showRouter = AppRouter.articles;

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

  /// 移动端的底部导航栏菜单
  final List<TRouterData> mobileMenus = [];

  /// 预览和发布
  final List<TActionData> actions = [];

  @override
  void initState() {
    super.initState();
    // 平板端
    if (Get.isTablet) {
      menus.add((name: Tran.setting, route: AppRouter.tabletSetting, icon: PhosphorIconsRegular.slidersHorizontal));
    }
    // 预览和发布两个操作按钮
    actions.add((name: Tran.preview, call: preview, icon: PhosphorIconsRegular.eye));
    actions.add((name: Tran.publishSite, call: publish, icon: PhosphorIconsRegular.cloudArrowUp));
    // 下面一行的按钮
    actions.add((name: Tran.setting, call: openSetting, icon: PhosphorIconsRegular.slidersHorizontal));
    actions.add((name: Tran.visitSite, call: openWebSite, icon: PhosphorIconsRegular.globe));
    actions.add((name: Tran.starSupport, call: starSupport, icon: PhosphorIconsRegular.githubLogo));

    mobileMenus.addAll(menus.take(3));
    mobileMenus.add((name: Tran.setting, route: AppRouter.phoneSetting, icon: PhosphorIconsRegular.slidersHorizontal));

    lifecycle = AppLifecycleListener(onStateChange: handleStateChange, onExitRequested: handleExitRequested);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取匹配的路由
    final route = !Get.isPhone ? desktopRouter.value : mobileMenus[mobileIndex.value].route;
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
  void onWindowClose() {
    print('onWindowClose');
    if (!site.isDisposed) {
      site.dispose();
    }
    super.onWindowClose();
  }

  @override
  Widget build(BuildContext context) {
    // 构建控件
    return Scaffold(
      body: SafeArea(
        child: site.obx(
          (data) {
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
    // 头像, 高度 kVerPadding16.top * 3 + kLogSize
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
    // 菜单列表高度
    const itemHeight = 50.0;
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
            constraints: const BoxConstraints.expand(height: itemHeight),
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
    // 最底部的按钮
    _addBottomButton(widgets);
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

  /// 添加底部的按钮
  void _addBottomButton(List<Widget> widgets) {
    if (Get.isTablet) {
      return;
    }
    // 插入一个空白, 进行填充中间的间隔
    widgets.add(Expanded(child: Container()));
    // 按钮
    widgets.add(Padding(
      padding: kVer8Hor32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 预览和发布按钮
          _buildActionButton(actions[0]),
          _buildActionButton(actions[1], isFilled: true),
          // 最底部的按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var item in actions.skip(2))
                TipWidget.up(
                  message: item.name.tr,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.expand(width: kButtonHeight, height: kButtonHeight),
                    onPressed: item.call,
                    icon: Icon(item.icon),
                  ),
                ),
            ],
          ),
        ],
      ),
    ));
  }

  /// 预览和发布按钮
  Widget _buildActionButton(TActionData item, {bool isFilled = false}) {
    // 按钮样式
    const buttonStyle = ButtonStyle(
      fixedSize: WidgetStatePropertyAll(Size(double.infinity, kButtonHeight)),
    );
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
        style: buttonStyle,
        child: Obx(() {
          if (!site.inBeingSync.value) {
            return contentWidget;
          }
          return const Align(
            alignment: Alignment.center,
            child: AutoAnimatedRotation(
              child: Icon(PhosphorIconsRegular.arrowsClockwise),
            ),
          );
        }),
      );
    } else {
      childWidget = OutlinedButton(
        onPressed: item.call,
        style: buttonStyle,
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
    if (!Get.isPhone) {
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
    Log.i('onExitRequested');
    if (!site.isDisposed) {
      try {
        await site.saveSiteData();
      } catch (e) {
        Log.e('$e');
      }
    }
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
  void preview() async {
    await site.previewSite();
  }

  /// 发布网页
  void publish() async {
    await site.publishSite();
  }

  /// 打开设置
  void openSetting() {
    // 显示抽屉
    Get.showDrawer(
      stepWidth: double.infinity,
      stepHeight: double.infinity,
      direction: DrawerDirection.bottomToTop,
      builder: (ctx) => const SettingEditor(),
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

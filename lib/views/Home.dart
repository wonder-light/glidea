import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Obx, Trans, IntExtension, StringExtension, GetNavigationExt;
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, this.title = '首页'});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  var selectedIndex = 0.obs;
  var routerIndex = '/articles'.obs;

  /// 菜单数据
  final List<({String route, String name, IconData icon})> menus = [
    (name: 'article', route: '/articles', icon: PhosphorIconsRegular.article),
    (name: 'menu', route: '/menu', icon: PhosphorIconsRegular.list),
    (name: 'tag', route: '/tags', icon: PhosphorIconsRegular.tag),
    (name: 'theme', route: '/theme', icon: PhosphorIconsRegular.tShirt),
    (name: 'remote', route: '/remote', icon: PhosphorIconsRegular.hardDrives),
  ];

  /// 预览和发布
  final List<({String name, VoidCallback call, IconData icon})> actions = [];

  @override
  void initState() {
    super.initState();
    var p = PhosphorIconsFill.acorn;
    // 预览和发布两个操作按钮
    actions.add((name: 'preview', call: preview, icon: PhosphorIconsRegular.eye));
    actions.add((name: 'publishSite', call: publish, icon: PhosphorIconsRegular.cloudArrowUp));
    // 下面一行的按钮
    actions.add((name: 'setting'.tr, call: openSetting, icon: PhosphorIconsRegular.slidersHorizontal));
    actions.add((name: 'visitSite'.tr, call: openSetting, icon: PhosphorIconsRegular.globe));
    actions.add((name: 'starSupport'.tr, call: openSetting, icon: PhosphorIconsRegular.githubLogo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _buildLeftPanel(),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建左边面板
  Widget _buildLeftPanel() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 200,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelUp(),
          _buildPanelBottom(),
        ],
      ),
    );
  }

  /// 构建面板的上部分
  Widget _buildPanelUp() {
    var colorScheme = Get.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 头像
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: const ClipOval(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              width: 64,
              height: 64,
            ),
          ),
        ),
        // 菜单列表
        for (var item in menus)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8, right: 10, left: 10),
            child: Obx(
              () => ListTile(
                onTap: () {
                  routerIndex.value = item.route;
                },
                leading: Icon(item.icon),
                title: Text(item.name.tr),
                trailing: const Text('10'),
                selected: routerIndex.value == item.route,
                selectedColor: colorScheme.surfaceContainerLow,
                selectedTileColor: colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
                minLeadingWidth: 0,
                minTileHeight: 0,
                visualDensity: const VisualDensity(horizontal: -4, vertical: 0),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建面板的下部分
  Widget _buildPanelBottom() {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 两个操作按钮
          for (var item in actions.take(2))
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton(
                onPressed: item.call,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Icon(item.icon),
                    ),
                    Text(item.name.tr),
                  ],
                ),
              ),
            ),
          // 一行的其它操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var item in actions.skip(2))
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.comfortable,
                  onPressed: item.call,
                  icon: Icon(item.icon),
                  tooltip: item.name,
                ),
            ],
          )
        ],
      ),
    );
  }

  /// 预览网页
  void preview() {}

  /// 发布网页
  void publish() {}

  /// 打开设置
  void openSetting() {}

  /// 打开发布在网站
  void openWebSite() {}

  /// 给个 start 支持
  void starSupport() {}

  /// 浏览主题市场
  void browseThemes() {}
}

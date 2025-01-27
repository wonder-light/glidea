import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/theme/theme.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  final themeKey = GlobalKey<ThemeWidgetState>();
  final customKey = GlobalKey<ThemeCustomWidgetState>();

  @override
  Widget build(BuildContext context) {
    // 手机端
    if (Get.isPhone) return buildPhone();
    // 主题和自定义主题的分组
    Widget childWidget = PageWidget(
      allowImplicitScrolling: false,
      groups: const [Tran.basicSetting, Tran.customConfig],
      itemBuilder: (ctx, index) {
        final isThemePage = index <= 0;
        final build = isThemePage ? ThemeWidget.new : ThemeCustomWidget.new;
        return build(key: isThemePage ? themeKey : customKey);
      },
    );
    // PC 端和平板端
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: childWidget),
          const Divider(thickness: 1, height: 1),
          buildBottom(),
        ],
      ),
    );
  }

  /// 构建手机端
  Widget buildPhone() {
    // arguments 参数来自 [package:glidea/views/setting.dart] 中的 [_SettingViewState.toRouter]
    final arg = Get.arguments as String;
    final isThemePage = Get.arguments != Tran.customConfig;
    final build = isThemePage ? ThemeWidget.new : ThemeCustomWidget.new;
    return Scaffold(
      appBar: AppBar(title: Text(arg.tr), actions: getActionButton()),
      body: build(key: isThemePage ? themeKey : customKey),
    );
  }

  /// 构建底部按钮
  Widget buildBottom() {
    return Padding(
      padding: kVer8Hor12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          OutlinedButton(onPressed: resetConfig, child: Text(Tran.reset.tr)),
          FilledButton(onPressed: saveConfig, child: Text(Tran.save.tr)),
        ],
      ),
    );
  }

  /// 手机端的 action 按钮
  List<Widget> getActionButton() {
    return [
      TipWidget.down(
        message: Tran.reset.tr,
        child: IconButton(
          onPressed: resetConfig,
          icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
        ),
      ),
      TipWidget.down(
        message: Tran.save.tr,
        child: IconButton(
          onPressed: saveConfig,
          icon: const Icon(PhosphorIconsRegular.archive),
        ),
      ),
    ];
  }

  /// 重置配置
  void resetConfig() {
    site.themeWidgetConfig.clear();
    site.themeCustomWidgetConfig.clear();
    themeKey.currentState?.loadData();
    customKey.currentState?.loadData();
  }

  /// 保存配置
  void saveConfig() async {
    // 保存前需要发出保存事件以便于图片进行保存
    final value = await site.saveThemeConfig(themes: site.themeWidgetConfig, customs: site.themeCustomWidgetConfig);
    value ? Get.success(Tran.themeConfigSaved) : Get.error(Tran.saveError);
    resetConfig();
  }
}

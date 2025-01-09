import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 主题配置
  final themeConfig = <ConfigBase>[].obs;

  /// 主题在加载中
  final themeLoading = false.obs;

  /// 自定义主题配置
  final themeCustomConfig = <ConfigBase>[].obs;

  /// 自定主题在加载中
  final customLoading = false.obs;

  @override
  void initState() {
    super.initState();
    site.isThemeCustomPage = false;
    if (Get.isPhone) {
      site.isThemeCustomPage = Get.arguments == Tran.customConfig;
      site.isThemeCustomPage! ? loadCustom() : loadTheme();
    } else {
      loadTheme();
    }
  }

  @override
  void dispose() {
    themeConfig.dispose();
    themeLoading.dispose();
    customLoading.dispose();
    themeCustomConfig.dispose();
    site.off(themeSaveEvent);
    site.isThemeCustomPage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 手机端
    if (Get.isPhone) return buildPhone();
    // 主题和自定义主题的分组
    Widget childWidget = GroupWidget(
      isTop: true,
      groups: const [Tran.basicSetting, Tran.customConfig],
      itemBuilder: (ctx, index) => index <= 0 ? buildThemeConfig() : buildCustomConfig(),
      onTap: (index) {
        site.isThemeCustomPage = index > 0;
        if (index > 0 && themeCustomConfig.value.isEmpty) {
          loadCustom();
        }
        if (index <= 0 && themeConfig.value.isEmpty) {
          loadTheme();
        }
      },
    );
    // PC 端和平板端
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
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
    var arg = Get.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text(arg.tr), actions: getActionButton()),
      body: site.isThemeCustomPage! ? buildCustomConfig() : buildThemeConfig(),
    );
  }

  /// 构建主题配置页面的内容
  Widget buildThemeConfig() {
    return Obx(() {
      if (themeLoading.value) {
        return const Center(child: LoadingWidget());
      }
      return _buildContent(themeConfig.value, isTop: false);
    });
  }

  /// 构建自定义主题配置页面的内容
  Widget buildCustomConfig() {
    return Obx(() {
      if (customLoading.value) {
        return const Center(child: LoadingWidget());
      }
      // 空的
      if (themeCustomConfig.value.isEmpty) {
        return Container(
          alignment: Alignment.center,
          padding: kAllPadding16,
          child: Text(Tran.noCustomConfigTip.tr),
        );
      }
      // 分组
      Map<String, List<ConfigBase>> groups = {};
      for (var t in themeCustomConfig.value) {
        (groups[t.group] ??= []).add(t);
      }
      // 只有一个
      if (groups.keys.length == 1) {
        return _buildContent(groups.values.first, isTop: false);
      }
      // 分组布局
      return GroupWidget(
        groups: groups.keys.toList(),
        itemBuilder: (ctx, index) => _buildContent(groups.values.elementAt(index)),
      );
    });
  }

  /// 从 [ConfigBase] 构建对应的控件
  Widget _buildContent(Iterable<ConfigBase> items, {bool isTop = true}) {
    return ListView.separated(
      shrinkWrap: true,
      padding: kHorPadding12 * 2 + kVerPadding16,
      itemCount: items.length,
      itemBuilder: (ctx, index) => ArrayWidget.create(config: items.elementAt(index), isVertical: isTop),
      separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
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
          onPressed: site.isThemeCustomPage! ? loadCustom : loadTheme,
          icon: const Icon(PhosphorIconsRegular.clockCounterClockwise),
        ),
      ),
      TipWidget.down(
        message: Tran.save.tr,
        child: IconButton(
          onPressed: saveConfig,
          icon: const Icon(PhosphorIconsRegular.boxArrowDown),
        ),
      ),
    ];
  }

  /// 加载主题
  Future<void> loadTheme() async {
    themeLoading.value = true;
    themeConfig.value = site.getThemeWidgetConfig();
    themeLoading.value = false;
  }

  /// 加载自定义主题
  Future<void> loadCustom() async {
    customLoading.value = true;
    themeCustomConfig.value = site.getThemeCustomWidgetConfig();
    customLoading.value = false;
  }

  /// 重置配置
  void resetConfig() {
    loadTheme();
    loadCustom();
  }

  /// 保存配置
  void saveConfig() async {
    // 保存前需要发出保存事件以便于图片进行保存
    await site.emit(themeSaveEvent);
    final value = await site.updateThemeConfig(themes: themeConfig.value, customs: themeCustomConfig.value);
    value ? Get.success(Tran.themeConfigSaved) : Get.error(Tran.saveError);
    resetConfig();
  }
}

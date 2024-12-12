import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/render.dart';

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  /// 是否可以保存
  var canSave = false.obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 主题配置
  final RxObject<List<ConfigBase>> themeConfig = <ConfigBase>[].obs;

  /// 自定义主题配置
  final RxObject<List<ConfigBase>> themeCustomConfig = <ConfigBase>[].obs;

  @override
  void initState() {
    super.initState();
    themeConfig.value.addAll(site.getThemeWidgetConfig());
    themeCustomConfig.value.addAll(site.getThemeCustomWidgetConfig());
    site.isThemeCustomPage = false;
  }

  @override
  void dispose() {
    canSave.dispose();
    themeConfig.dispose();
    themeCustomConfig.dispose();
    site.off(themeSaveEvent);
    site.isThemeCustomPage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GroupWidget(
              isTop: true,
              groups: const {'basicSetting', 'customConfig'},
              children: [
                buildThemeConfig(),
                buildCustomConfig(),
              ],
              onTap: (index) => site.isThemeCustomPage = index > 0,
            ),
          ),
          buildBottom(),
        ],
      ),
    );
  }

  /// 构建主题配置页面的内容
  Widget buildThemeConfig() {
    return Obx(() => _buildContent(themeConfig.value, isTop: false));
  }

  /// 构建自定义主题配置页面的内容
  Widget buildCustomConfig() {
    return Obx(() {
      if (themeCustomConfig.value.isEmpty) {
        return Container(
          alignment: Alignment.center,
          padding: kAllPadding16,
          child: Text('noCustomConfigTip'.tr),
        );
      }

      Map<String, List<ConfigBase>> groups = {};
      for (var t in themeCustomConfig.value) {
        (groups[t.group] ??= []).add(t);
      }

      if (groups.keys.length == 1 && groups.keys.first.isEmpty) {
        return _buildContent(groups.values.first, isTop: false);
      }

      return GroupWidget(
        groups: groups.keys.toSet(),
        children: [
          for (var items in groups.values) _buildContent(items),
        ],
      );
    });
  }

  Widget _buildContent(List<ConfigBase> items, {bool isTop = true}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: kVer12Hor24,
          child: ArrayWidget.create(config: items[index], isVertical: isTop),
        );
      },
    );
  }

  /// 构建底部按钮
  Widget buildBottom() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 0.4,
            color: Get.theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: kVer8Hor12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          OutlinedButton(
            onPressed: resetConfig,
            child: Text('reset'.tr),
          ),
          FilledButton(
            onPressed: saveConfig,
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  /// 重置配置
  void resetConfig() {
    // 主题配置
    themeConfig.value = site.getThemeWidgetConfig();
    themeCustomConfig.value = site.getThemeCustomWidgetConfig();
  }

  /// 保存配置
  void saveConfig() async {
    try {
      // 保存前需要发出保存事件以便于图片进行保存
      await site.emit(themeSaveEvent);
      site.updateThemeConfig(themes: themeConfig.value, customs: themeCustomConfig.value);
      resetConfig();
    } catch (e) {
      Get.error('saveError');
    }
  }
}

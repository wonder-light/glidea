import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, GetView, Inst, Obx, StateExt, Trans;
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/views/loading.dart';

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {
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
    themeConfig.value.addAll(site.getThemeWidget());
    themeCustomConfig.value.addAll(site.getThemeCustomWidget());
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = site.obx(
      (data) {
        return GroupWidget(
          isTop: true,
          isScrollable: true,
          groups: const {'basicSetting', 'customConfig'},
          children: [
            SingleChildScrollView(
              child: buildThemeConfig(),
            ),
            buildCustomConfig(),
          ],
        );
      },
      onLoading: const LoadingWidget(hint: 'inConfig'),
    );

    childWidget = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: childWidget),
        buildBottom(),
      ],
    );
    return childWidget;
  }

  /// 构建主题配置页面的内容
  Widget buildThemeConfig() {
    return Obx(() {
      return _buildContent(themeConfig.value, isTop: false);
    });
  }

  /// 构建自定义主题配置页面的内容
  Widget buildCustomConfig() {
    return Obx(() {
      if (themeCustomConfig.value.isEmpty) {
        return Container(
          alignment: Alignment.center,
          padding: kTopPadding16,
          child: Text('noCustomConfigTip'.tr),
        );
      }

      Map<String, List<ConfigBase>> groups = {};
      for (var t in themeCustomConfig.value.reversed) {
        (groups[t.group] ??= []).add(t);
      }

      if (groups.keys.length == 1 && groups.keys.first.isEmpty) {
        return SingleChildScrollView(
          child: _buildContent(groups.values.first),
        );
      }

      return GroupWidget(
        groups: groups.keys.toSet(),
        isScroll: true,
        isScrollable: true,
        initialIndex: groups.keys.length - 1,
        children: [
          for (var items in groups.values) _buildContent(items),
        ],
      );
    });
  }

  Widget _buildContent(List<ConfigBase> items, {bool isTop = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(padding: kVerPadding4),
        for (var item in items)
          Padding(
            padding: kHorPadding12 * 2 + (isTop ? EdgeInsets.zero : kVerPadding8),
            child: ArrayWidget.create(config: item, isTop: isTop),
          ),
      ],
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
    themeConfig.value = site.getThemeWidget();
    themeCustomConfig.value = site.getThemeCustomWidget();
  }

  /// 保存配置
  void saveConfig() {
    site.updateThemeConfig(themes: themeConfig.value, customs: themeCustomConfig.value);
    resetConfig();
  }
}

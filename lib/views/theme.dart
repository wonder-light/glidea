import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/render.dart';

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
  ///
  /// 字段的类型 -- 字段的默认值
  final RxObject<List<ConfigBase>> themeConfig = <ConfigBase>[].obs;

  @override
  void initState() {
    super.initState();
    themeConfig.value.addAll(site.getThemeWidgetConfig());
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = GroupWidget(
      isTop: true,
      isScrollable: true,
      groups: const {'basicSetting', 'customConfig'},
      children: [
        buildThemeConfig(),
        if (site.themeCustomConfig.isEmpty)
          Container(
            alignment: Alignment.center,
            child: Text('noCustomConfigTip'.tr),
          )
        else
          GroupWidget(
            groups: const {'basicSetting', 'customConfig'},
            children: [
              Container(
                color: Colors.accents[Random().nextInt(10)],
              ),
              Container(
                color: Colors.accents[Random().nextInt(10)],
              ),
            ],
          ),
      ],
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
      List<Widget> children = [];
      for (var item in themeConfig.value) {
        Widget child = ArrayWidget.create(config: item, isTop: false);
        child = Padding(
          padding: kVerPadding8 * 2,
          child: child,
        );
        children.add(child);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    });
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
  }

  /// 保存配置
  void saveConfig() {
    site.updateThemeConfig(themeConfig.value);
    resetConfig();
  }
}

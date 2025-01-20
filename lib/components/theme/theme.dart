import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, Inst, Obx, Trans;
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/render/base.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';

typedef TAsync = ValueSetter<AsyncCallback>;

/// 主题控件
class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => ThemeWidgetState();
}

class ThemeWidgetState extends State<ThemeWidget> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 主题配置在加载中
  final isLoading = false.obs;

  /// 主题配置
  final configs = <ConfigBase>[].obs;

  /// 图片的限定范围
  ///
  ///     > 0  => 主题
  ///     = 0  => 自定义主题
  ///     < 0  => 其它
  final int pictureScope = 1;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: LoadingWidget());
      }
      return _buildContent(configs.value, isTop: false);
    });
  }

  /// 从 [ConfigBase] 构建对应的控件
  Widget _buildContent(Iterable<ConfigBase> items, {bool isTop = true}) {
    return ListView.separated(
      shrinkWrap: true,
      padding: kHorPadding12 * 2 + kVerPadding16,
      itemCount: items.length,
      itemBuilder: (ctx, index) => ArrayWidget.create(config: items.elementAt(index), isVertical: isTop, scope: pictureScope),
      separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
    );
  }

  /// 加载主题
  Future<void> loadData() async {
    if (site.themeWidgetConfig.isEmpty) {
      isLoading.value = true;
      site.themeWidgetConfig.addAll(site.getThemeWidgetConfig());
    }
    configs.value = site.themeWidgetConfig;
    isLoading.value = false;
  }
}

/// 自定义主题控件
class ThemeCustomWidget extends ThemeWidget {
  const ThemeCustomWidget({super.key});

  @override
  State<ThemeWidget> createState() => ThemeCustomWidgetState();
}

class ThemeCustomWidgetState extends ThemeWidgetState {
  @override
  int get pictureScope => 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: LoadingWidget());
      }
      // 空的
      if (configs.value.isEmpty) {
        return Container(
          alignment: Alignment.center,
          padding: kAllPadding16,
          child: Text(Tran.noCustomConfigTip.tr),
        );
      }
      // 分组
      Map<String, List<ConfigBase>> groups = {};
      for (var t in configs.value) {
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

  @override
  Future<void> loadData() async {
    if (site.themeCustomWidgetConfig.isEmpty) {
      isLoading.value = true;
      await Future.wait([
        _loadConfig(),
        Future.delayed(Duration(milliseconds: 200)),
      ]);
    }
    configs.value = site.themeCustomWidgetConfig;
    isLoading.value = false;
  }

  /// 加载配置
  Future<void> _loadConfig() async {
    final value = await site.loadThemeCustomConfig();
    site.themeCustomWidgetConfig.addAll(value);
  }
}

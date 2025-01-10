import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx, Trans;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/setting/setting_editor.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

class HomeDownPanel extends StatefulWidget {
  const HomeDownPanel({super.key});

  @override
  State<HomeDownPanel> createState() => _HomeDownPanelState();
}

class _HomeDownPanelState extends State<HomeDownPanel> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 是否这正在同步中
  final inBeingSync = false.obs;

  /// 预览是否这正在同步中
  final inPreviewSync = false.obs;

  // 按钮样式
  final buttonStyle = const ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size(double.infinity, kButtonHeight)),
  );

  /// 预览和发布
  late final Map<bool, TActionData> buttons = {
    false: (name: Tran.preview, call: preview, icon: PhosphorIconsRegular.eye),
    true: (name: Tran.publishSite, call: publish, icon: PhosphorIconsRegular.cloudArrowUp),
  };

  /// icon 按钮
  late final List<TActionData> iconActions = [
    (name: Tran.setting, call: openSetting, icon: PhosphorIconsRegular.slidersHorizontal),
    (name: Tran.visitSite, call: openWebSite, icon: PhosphorIconsRegular.globe),
    (name: Tran.starSupport, call: starSupport, icon: PhosphorIconsRegular.githubLogo),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kVer8Hor32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var MapEntry(:key, :value) in buttons.entries) _buildButton(isFilled: key, item: value),
          // 最底部的图标按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var item in iconActions)
                TipWidget.up(
                  message: item.name.tr,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: kButtonHeight, height: kButtonHeight),
                    onPressed: item.call,
                    icon: Icon(item.icon),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 预览和发布按钮
  Widget _buildButton({required TActionData item, bool isFilled = false}) {
    final build = isFilled ? FilledButton.new : OutlinedButton.new;
    // 内容
    Widget contentWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon),
        const Padding(padding: kRightPadding8),
        Text(item.name.tr),
      ],
    );
    // 包裹
    Widget content = Obx(() {
      Widget widget = contentWidget;
      if((isFilled && inBeingSync.value) || (!isFilled && inPreviewSync.value)) {
        widget = const Align(
          alignment: Alignment.center,
          child: AutoAnimatedRotation(
            child: Icon(PhosphorIconsRegular.arrowsClockwise),
          ),
        );
      }
      return widget;
    });
    // 返回
    return Padding(
      padding: kVerPadding8,
      child: build(
        onPressed: item.call,
        style: buttonStyle,
        child: content,
      ),
    );
  }

  /// 预览网页
  void preview() async {
    inPreviewSync.value = true;
    final notif = await site.previewSite();
    notif.exec();
    inPreviewSync.value = false;
  }

  /// 发布网页
  void publish() async {
    inBeingSync.value = true;
    final notif = await site.publishSite();
    notif.exec();
    inBeingSync.value = false;
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
}

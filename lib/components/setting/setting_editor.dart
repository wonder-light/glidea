import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, GetStringUtils, Inst, Trans;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/render.dart';
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

class SettingEditor extends DrawerEditor<Object> {
  const SettingEditor({
    super.key,
    required super.entity,
    required super.controller,
    super.onClose,
    super.onSave,
    super.header = 'save',
    super.hideCancel = true,
  });

  @override
  SettingEditorState createState() => SettingEditorState();
}

class SettingEditorState extends DrawerEditorState<Object> {
  /// 语言
  final language = SelectConfig().obs;

  /// 站点目录
  final siteDir = InputConfig().obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  final languageOptions = [
    SelectOption().setValues(label: '简体中文', value: 'zh_CN'),
    SelectOption().setValues(label: 'English', value: 'en_US'),
    SelectOption().setValues(label: '繁體中文', value: 'zh_TW'),
    SelectOption().setValues(label: 'Français', value: 'fr_FR'),
    SelectOption().setValues(label: 'русск', value: 'ru_RU'),
    SelectOption().setValues(label: '日本語', value: 'ja_JP'),
  ];

  @override
  void initState() {
    super.initState();
    canSave.value = true;
    language.value
      ..label = 'language'
      ..value = 'zh_CN'
      ..options = languageOptions;

    siteDir.value
      ..value = site.state.appDir
      ..label = 'sourceFolder';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: super.build(context),
    );
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    var pad = kVerPadding8 * 2;
    return [
      SelectWidget(config: language),
      Padding(padding: pad),
      FileSelectWidget(config: siteDir),
      Padding(padding: pad),
      Padding(
        padding: kVerPadding8,
        child: Text('version'.tr),
      ),
      Padding(
        padding: kTopPadding8,
        child: Text(site.state.version),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: openUrl,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Text(
            site.state.appName.capitalizeFirst,
            style: Get.textTheme.bodyMedium!.copyWith(
              color: Get.theme.primaryColor,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  void onSave() async {
    if (!canSave.value) return;
    try {
      await site.saveSiteData();
      Get.success('saveSuccess');
    } catch (e) {
      Get.error('saveError');
    }
  }

  void openUrl() async {
    final success = await launchUrlString('https://github.com/wonder-light/glidea');
    if (!success) {
      Log.i('github 打开失败');
    }
  }
}

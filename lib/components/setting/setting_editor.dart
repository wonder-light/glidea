import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart' show Get, GetNavigationExt, GetStringUtils, Trans;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/render/base.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/render.dart';
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

/// 大窗下的设置配置控件
class SettingEditor extends DrawerEditor<Object> {
  const SettingEditor({
    super.key,
    super.entity = const Object(),
    super.controller,
    super.onClose,
    super.onSave,
    super.header = 'save',
    super.hideCancel = true,
    this.isVertical = true,
  });

  /// true: 标题在顶部
  ///
  // false: 标题在前面
  final bool isVertical;

  @override
  SettingEditorState createState() => SettingEditorState();
}

class SettingEditorState extends DrawerEditorState<SettingEditor> {
  /// 语言
  final language = SelectConfig().obs;

  /// 站点目录
  final siteDir = InputConfig().obs;

  /// 预览端口
  final previewPort = InputConfig().obs;

  /// 版本
  final version = InputConfig();

  @override
  void initState() {
    super.initState();
    canSave.value = true;
    final app = site.state;
    language.value
      ..label = 'language'
      ..value = app.language
      ..options = [
        for (var item in site.languages.entries)
          SelectOption().setValues(
            label: item.value,
            value: item.key,
          ),
      ];

    siteDir.value
      ..value = app.appDir
      ..label = 'sourceFolder';

    previewPort.value
      ..label = 'previewPort'.tr
      ..value = '${app.previewPort}';

    version
      ..label = 'version'.tr
      ..value = app.version;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: super.build(context),
    );
  }

  @override
  Widget buildHeader(BuildContext context) {
    if (Get.isTablet) {
      return Container();
    }
    return super.buildHeader(context);
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    final pad = kVerPadding8 * 2;
    final formatters = [FilteringTextInputFormatter(RegExp(r'[0-9]*'), allow: true)];
    return [
      SelectWidget(config: language, isVertical: widget.isVertical),
      Padding(padding: pad),
      FileSelectWidget(config: siteDir, isReadOnly: false, isVertical: widget.isVertical),
      Padding(padding: pad),
      InputWidget(config: previewPort, isVertical: widget.isVertical, inputFormatters: formatters),
      Padding(padding: pad),
      ConfigLayoutWidget(isVertical: widget.isVertical, config: version, child: _buildVersion()),
    ];
  }

  /// 构建版本号
  Widget _buildVersion() {
    final theme = Get.theme;
    return Padding(
      padding: kTopPadding8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: kRightPadding8,
            child: Text(version.value),
          ),
          GestureDetector(
            onTap: openUrl,
            child: MouseRegion(
              cursor: WidgetStateMouseCursor.clickable,
              child: Text(
                site.state.appName.capitalizeFirst,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onSave() async {
    if (!canSave.value) return;
    try {
      // 设置目录
      site.state.appDir = siteDir.value.value;
      // 设置语言代码
      site.setLanguage(language.value.value);
      // 保存数据
      await site.saveSiteData();
      // 刷新当前页面
      setState(() {});
      // 进行通知
      Get.success('saveSuccess');
    } catch (e) {
      Get.error('saveError\n$e');
    }
  }

  /// 打开 URL
  void openUrl() async {
    final success = await launchUrlString('https://github.com/wonder-light/glidea');
    if (!success) {
      Log.w('github 打开失败');
    }
  }
}

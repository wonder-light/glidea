import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart' show Get, GetNavigationExt, GetStringUtils, Obx, Trans, WidgetCallback;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/render/base.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
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

  /// 预览
  final preview = InputConfig();

  /// 发布
  final publish = InputConfig();

  /// 访问网站
  final visitSite = InputConfig();

  /// 在预览中
  final inPreview = false.obs;

  /// 在发布中
  final inPublish = false.obs;

  /// 文本格式化 - 只能输入数字
  FilteringTextInputFormatter numberFormat = FilteringTextInputFormatter(RegExp(r'[0-9]*'), allow: true);

  /// 需要使用的控件构建函数
  List<WidgetCallback> callbacks = [];

  /// 按钮样式
  final _iconButtonStyle = const ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size(kButtonHeight * 3, kButtonHeight)),
  );

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

    preview.label = 'preview'.tr;
    publish.label = 'publishSite'.tr;
    visitSite.label = 'visitSite'.tr;

    final isTablet = Get.isTablet;
    callbacks.addAll([
      _buildLanguage,
      _buildFileSelect,
      _buildPreviewPort,
      _buildVersion,
      if (isTablet) _buildPreview,
      if (isTablet) _buildPublish,
      if (isTablet) _buildVisitSite,
    ]);
  }

  @override
  void dispose() {
    language.dispose();
    siteDir.dispose();
    previewPort.dispose();
    inPreview.dispose();
    inPublish.dispose();
    super.dispose();
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
  Widget buildActions(BuildContext context) {
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
      alignment: Alignment.centerRight,
      child: FilledButton(
        style: super.actionStyle,
        onPressed: canSave.value ? onSave : null,
        child: Text('save'.tr),
      ),
    );
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    final pad = kVerPadding8 * 2;
    return [
      for (var call in callbacks) ...[
        call(),
        Padding(padding: pad),
      ],
    ];
  }

  /// 语言选择
  Widget _buildLanguage() => SelectWidget(config: language, isVertical: widget.isVertical);

  /// 文件夹选择
  Widget _buildFileSelect() => FileSelectWidget(config: siteDir, isReadOnly: false, isVertical: widget.isVertical);

  /// 预览端口
  Widget _buildPreviewPort() => InputWidget(config: previewPort, isVertical: widget.isVertical, inputFormatters: [numberFormat]);

  /// 构建版本号
  Widget _buildVersion() {
    final theme = Get.theme;
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: version,
      child: Padding(
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
      ),
    );
  }

  /// 预览
  Widget _buildPreview() => _buildPublish(isPublish: false);

  /// 发布
  Widget _buildPublish({bool isPublish = true}) {
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: isPublish ? publish : preview,
      child: OutlinedButton(
        style: _iconButtonStyle,
        onPressed: () => clickButton(isPublish: isPublish),
        child: Obx(() {
          final value = isPublish ? inPublish : inPreview;
          if (value.value) {
            return const Align(
              child: AutoAnimatedRotation(
                child: Icon(PhosphorIconsRegular.arrowsClockwise),
              ),
            );
          }
          return Icon(isPublish ? PhosphorIconsRegular.cloudArrowUp : PhosphorIconsRegular.eye);
        }),
      ),
    );
  }

  // 访问网站
  Widget _buildVisitSite() {
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: visitSite,
      child: OutlinedButton(
        style: _iconButtonStyle,
        onPressed: !site.checkPublish ? null : () => clickButton(isPublish: null),
        child: const Icon(PhosphorIconsRegular.globe),
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
      // 端口
      site.state.previewPort = int.tryParse(previewPort.value.value) ?? site.state.previewPort;
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

  /// 点击按钮
  void clickButton({bool? isPublish}) async {
    if (isPublish == null) {
      try {
        await launchUrlString(site.domain);
      } catch (e) {
        Log.i('网站打开失败 ${site.domain}');
      }
    } else if (isPublish) {
      await site.publishSite();
    } else {
      await site.previewSite();
    }
  }
}

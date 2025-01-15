import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart' show Get, GetNavigationExt, GetStringUtils, Inst, Obx, Trans, WidgetCallback;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/render/base.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

/// 大窗下的设置配置控件
class SettingEditor extends StatefulWidget {
  const SettingEditor({
    super.key,
    this.isVertical = true,
  });

  /// true: 标题在顶部
  ///
  // false: 标题在前面
  final bool isVertical;

  @override
  SettingEditorState createState() => SettingEditorState();
}

class SettingEditorState extends State<SettingEditor> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 语言
  late final RxObject<SelectConfig> language;

  /// 站点目录
  late final RxObject<InputConfig> sourceFolder;

  /// 预览端口
  late final RxObject<InputConfig> previewPort;

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

  /// 配置
  final TMap<ConfigBase> configs = {};

  /// 主题数据
  final theme = Theme.of(Get.context!);

  @override
  void initState() {
    super.initState();
    final app = site.state;
    configs.addAll(site.createRenderConfig(
      fields: {
        Tran.language: FieldType.select,
        Tran.sourceFolder: FieldType.input,
        Tran.previewPort: FieldType.input,
        Tran.version: FieldType.input,
        Tran.preview: FieldType.input,
        Tran.publishSite: FieldType.input,
        Tran.visitSite: FieldType.input,
        Tran.log: FieldType.input,
      },
      fieldValues: {
        Tran.language: app.language,
        Tran.sourceFolder: app.appDir,
        Tran.previewPort: '${app.previewPort}',
        Tran.version: app.version,
      },
      options: {
        Tran.language: [for (var t in site.languages.entries) SelectOption().setValues(label: t.value, value: t.key)],
      },
    ));

    language = (configs[Tran.language] as SelectConfig).obs;
    sourceFolder = (configs[Tran.sourceFolder] as InputConfig).obs;
    previewPort = (configs[Tran.previewPort] as InputConfig).obs;

    final isMobile = !Get.isDesktop;
    callbacks.addAll([
      _buildLanguage,
      _buildFileSelect,
      _buildPreviewPort,
      _buildVersion,
      _viewLogs,
      if (isMobile) _buildPreview,
      if (isMobile) _buildPublish,
      if (isMobile) _buildVisitSite,
    ]);
  }

  @override
  void dispose() {
    language.dispose();
    sourceFolder.dispose();
    previewPort.dispose();
    inPreview.dispose();
    inPublish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Get.isDesktop ? Tran.setting.tr : Tran.otherSetting.tr),
        actions: [
          TipWidget.down(
            message: Tran.save.tr,
            child: IconButton(
              onPressed: onSave,
              icon: const Icon(PhosphorIconsRegular.downloadSimple),
            ),
          ),
          const Padding(padding: kRightPadding16),
        ],
      ),
      body: ListView.separated(
        shrinkWrap: true,
        padding: kHorPadding16 + kVerPadding8,
        itemCount: callbacks.length,
        itemBuilder: (ctx, index) => callbacks[index](),
        separatorBuilder: (ctx, index) => const Padding(padding: kVerPadding8),
      ),
    );
  }

  /// 语言选择
  Widget _buildLanguage() => SelectWidget(config: language, isVertical: widget.isVertical);

  /// 文件夹选择
  Widget _buildFileSelect() => FileSelectWidget(config: sourceFolder, isReadOnly: false, isVertical: widget.isVertical);

  /// 预览端口
  Widget _buildPreviewPort() => InputWidget(config: previewPort, isVertical: widget.isVertical, inputFormatters: [numberFormat]);

  /// 构建版本号
  Widget _buildVersion() {
    final version = configs[Tran.version]!;
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: version,
      child: Padding(
        padding: kTopPadding8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(version.value),
            const Padding(padding: kRightPadding8),
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

  /// 查看日志
  Widget _viewLogs() {
    return ConfigLayoutWidget(
        isVertical: widget.isVertical,
        config: configs[Tran.log]!,
        child: OutlinedButton(
          style: _iconButtonStyle,
          onPressed: openLogView,
          child: const Icon(PhosphorIconsRegular.log),
        ));
  }

  /// 发布
  Widget _buildPublish() => _buildButton(type: 1);

  /// 预览
  Widget _buildPreview() => _buildButton(type: 0);

  // 访问网站
  Widget _buildVisitSite() => _buildButton(type: -1);

  /// 构建按钮
  ///
  ///     type > 0 publish
  ///     type = 0 preview
  ///     type < 0 visitSite
  Widget _buildButton({int type = 0}) {
    final config = switch (type) {
      > 0 => configs[Tran.publishSite],
      == 0 => configs[Tran.preview],
      _ => configs[Tran.visitSite],
    };
    Widget content;
    VoidCallback? pressed = () => clickButton(type: type);
    // 浏览网站
    if (type < 0) {
      content = const Icon(PhosphorIconsRegular.globe);
      if (!site.checkPublish) {
        pressed = null;
      }
    } else {
      content = Obx(() {
        final run = type > 0 ? inPublish : inPreview;
        if (run.value) {
          return const Align(
            child: AutoAnimatedRotation(
              child: Icon(PhosphorIconsRegular.arrowsClockwise),
            ),
          );
        }
        return Icon(type > 0 ? PhosphorIconsRegular.cloudArrowUp : PhosphorIconsRegular.eye);
      });
    }
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: config!,
      child: OutlinedButton(
        style: _iconButtonStyle,
        onPressed: pressed,
        child: content,
      ),
    );
  }

  /// 构建打开的日志视图
  Widget _buildLogView(BuildContext context) {
    final str = StringBuffer();
    for (var item in Log.buffer) {
      str.writeAll(item.lines, '\n');
      str.write('\n\n');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(Tran.log.tr),
        actions: [
          TipWidget.down(
            message: Tran.delete.tr,
            child: IconButton(
              onPressed: () => Log.buffer.clear(),
              icon: const Icon(PhosphorIconsRegular.trash),
            ),
          ),
          const Padding(padding: kRightPadding16),
        ],
      ),
      body: SingleChildScrollView(
        child: Text.rich(TextSpan(text: str.toString())),
      )
    );
  }

  /// 保存数据
  void onSave() async {
    try {
      // 设置目录
      site.state.appDir = sourceFolder.value.value;
      // 设置语言代码
      site.setLanguage(language.value.value);
      // 端口
      site.state.previewPort = int.tryParse(previewPort.value.value) ?? site.state.previewPort;
      // 保存数据
      await site.saveSiteData();
      // 刷新当前页面
      setState(() {});
      // 进行通知
      Get.success(Tran.saveSuccess);
    } catch (e, s) {
      Log.e('Failed to save data in the Settings screen on the large screen. Procedure', error: e, stackTrace: s);
      Get.error(Tran.saveError);
    }
  }

  /// 打开 URL
  void openUrl() async {
    final success = await launchUrlString('https://github.com/wonder-light/glidea');
    if (!success) {
      Log.w('github 打开失败');
    }
  }

  /// TODO: 检查更新
  void checkUpdate() async {}

  /// 打开日志视图
  void openLogView() {
    Get.showDrawer(
      direction: DrawerDirection.center,
      stepWidth: double.infinity,
      builder: _buildLogView,
    );
  }

  /// 点击按钮
  ///
  ///     type > 0 publish
  ///     type = 0 preview
  ///     type < 0 visitSite
  void clickButton({int type = 0}) async {
    if (type < 0) {
      if (!await launchUrlString(site.domain)) {
        Log.i('website opening failure ${site.domain}');
      }
      return;
    }
    // 更改显示的 Icon
    final run = type > 0 ? inPublish : inPreview;
    run.value = true;
    // 执行
    final notif = type > 0 ? await site.publishSite() : await site.previewSite();
    notif.exec();
    // 还原 Icon
    run.value = false;
  }
}

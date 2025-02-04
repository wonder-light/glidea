import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/remote/comment.dart';
import 'package:glidea/components/remote/remote.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 正在进行远程检测中
  final inRemoteDetect = false.obs;

  final remoteKey = GlobalKey<RemoteSettingWidgetState>();
  final commentKey = GlobalKey<CommentSettingWidgetState>();

  @override
  Widget build(BuildContext context) {
    // 手机端
    if (Get.isPhone) {
      return buildPhone();
    }
    // 远程和评论的分组
    return PageWidget(
      contentPadding: kTopPadding16,
      groups: const [Tran.basicSetting, Tran.commentSetting],
      itemBuilder: (ctx, index) => index > 0 ? CommentSettingWidget(key: commentKey) : RemoteSettingWidget(key: remoteKey),
      actions: getActionButton(),
    );
  }

  /// 构建手机端
  Widget buildPhone() {
    // arguments 参数来自 [package:glidea/views/setting.dart] 中的 [_SettingViewState.toRouter]
    final arg = Get.arguments as String;
    final isRemote = arg != Tran.commentSetting;
    final childWidget = isRemote ? RemoteSettingWidget(key: remoteKey) : CommentSettingWidget(key: commentKey);
    return Scaffold(
      appBar: AppBar(
        title: Text(arg.tr),
        actions: getActionButton(hasExport: isRemote),
      ),
      body: childWidget,
    );
  }

  /// 构建 action 按钮
  List<Widget> getActionButton({bool hasExport = true}) {
    return [
      if (hasExport)
        TipWidget.down(
          message: Tran.export.tr,
          child: IconButton(
            onPressed: _exportZipFile,
            icon: Icon(PhosphorIconsRegular.export),
          ),
        ),
      Obx(() {
        final detect = inRemoteDetect.value;
        final icon = detect ? Icon(PhosphorIconsRegular.arrowsClockwise) : Icon(PhosphorIconsRegular.clockCounterClockwise);
        return TipWidget.down(
          message: Tran.testConnection.tr,
          child: IconButton(
            onPressed: inRemoteDetect.value ? null : _testConnection,
            icon: inRemoteDetect.value ? AutoAnimatedRotation(child: icon) : icon,
          ),
        );
      }),
      TipWidget.down(
        message: Tran.save.tr,
        child: IconButton(
          onPressed: _saveConfig,
          icon: Icon(PhosphorIconsRegular.boxArrowDown),
        ),
      ),
    ];
  }

  /// 保持配置
  void _saveConfig() async {
    final value = await site.saveRemoteConfig();
    await remoteKey.currentState?.resetConfig();
    await commentKey.currentState?.resetConfig();
    value ? Get.success(Tran.themeConfigSaved) : Get.error(Tran.saveError);
  }

  /// 检测远程连接
  void _testConnection() async {
    inRemoteDetect.value = true;
    final value = await site.remoteDetect();
    value ? Get.success(Tran.connectSuccess) : Get.error(Tran.connectFailed);
    inRemoteDetect.value = false;
  }

  /// 导出 zip 文件
  void _exportZipFile() async {
    // 选择的目录
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;
    // 时间
    final time = DateTime.now().format(pattern: 'yyyy-MM-dd HH-mm-ss');
    // 创建 zip 文件
    final value = await site.exportZipFile('$selectedDirectory/Glidea-$time.zip');
    value ? Get.success(Tran.saved) : Get.error(Tran.saveError);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/animated.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/remote/comment.dart';
import 'package:glidea/components/remote/remote.dart';
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 手机端的操作数据
  late final List<TActionData> actions;

  /// 正在进行远程检测中
  final inRemoteDetect = false.obs;

  final remoteKey = GlobalKey<RemoteSettingWidgetState>();
  final commentKey = GlobalKey<CommentSettingWidgetState>();

  @override
  void initState() {
    super.initState();
    // 初始化配置
    if (Get.isPhone) {
      actions = [
        (name: Tran.testConnection, call: _testConnection, icon: PhosphorIconsRegular.clockCounterClockwise),
        (name: Tran.save, call: _saveConfig, icon: PhosphorIconsRegular.downloadSimple),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    // 手机端
    if (Get.isPhone) {
      // arguments 参数来自 [package:glidea/views/setting.dart] 中的 [_SettingViewState.toRouter]
      var arg = Get.arguments as String;
      childWidget = arg == Tran.commentSetting ? CommentSettingWidget(key: commentKey) : RemoteSettingWidget(key: remoteKey);
      return Scaffold(
        appBar: AppBar(
          title: Text(arg.tr),
          actions: [
            for (var item in actions)
              TipWidget.down(
                message: item.name.tr,
                child: IconButton(
                  onPressed: item.call,
                  icon: Icon(item.icon),
                ),
              ),
          ],
        ),
        body: Padding(padding: kTopPadding16, child: childWidget),
      );
    }
    // 远程和评论的分组
    childWidget = GroupWidget(
      isTop: true,
      contentPadding: kTopPadding16,
      groups: const [Tran.basicSetting, Tran.commentSetting],
      itemBuilder: (ctx, index) => index > 0 ? CommentSettingWidget(key: commentKey) : RemoteSettingWidget(key: remoteKey),
    );
    // 返回
    return Material(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: childWidget),
          const VerticalDivider(thickness: 1, width: 1),
          _buildBottom(),
        ],
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottom() {
    return Padding(
      padding: kVer8Hor12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Obx(() {
            Widget child = Text(Tran.testConnection.tr);
            if (inRemoteDetect.value) {
              child = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AutoAnimatedRotation(child: Icon(PhosphorIconsRegular.arrowsClockwise)),
                  child,
                ],
              );
            }
            return TipWidget.up(
              message: Tran.saveConfig.tr,
              child: OutlinedButton(
                onPressed: inRemoteDetect.value ? null : _testConnection,
                child: child,
              ),
            );
          }),
          FilledButton(
            onPressed: _saveConfig,
            child: Text(Tran.save.tr),
          ),
        ],
      ),
    );
  }

  /// 保持配置
  void _saveConfig() async {
    // 提取配置的值
    TJsonMap getConfig(Map<Object, TMap<ConfigBase>>? configs) {
      if (configs?.isEmpty ?? true) return {};
      return {
        for (var MapEntry(:key, :value) in configs!.entries)
          if (key is Enum)
            key.name: {
              for (var entry in value.entries) entry.key: entry.value.value,
            }
          else
            for (var entry in value.entries) entry.key: entry.value.value,
      };
    }

    // 获取配置
    TJsonMap remotes = getConfig(remoteKey.currentState?.configs.value);
    TJsonMap comments = getConfig(commentKey.currentState?.configs.value);
    final value = await site.updateRemoteConfig(remotes: remotes, comments: comments);
    await remoteKey.currentState?.initConfig();
    await commentKey.currentState?.initConfig();
    value ? Get.success(Tran.themeConfigSaved) : Get.error(Tran.saveError);
  }

  /// 检测远程连接
  void _testConnection() async {
    inRemoteDetect.value = true;
    final value = await site.remoteDetect();
    value ? Get.success(Tran.connectSuccess) : Get.error(Tran.connectFailed);
    inRemoteDetect.value = false;
  }
}

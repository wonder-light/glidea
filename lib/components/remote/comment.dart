import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst;
import 'package:glidea/components/render/base.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';

/// 评论设置控件
class CommentSettingWidget extends StatefulWidget {
  const CommentSettingWidget({super.key});

  @override
  State<StatefulWidget> createState() => CommentSettingWidgetState();
}

class CommentSettingWidgetState extends State<CommentSettingWidget> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 平台
  late Enum platform;

  /// 需要隐藏密码的字段
  TMap<bool> hidePasswords = {};

  @override
  void initState() {
    super.initState();
    initConfig();
  }

  @override
  Widget build(BuildContext context) {
    final items = getConfigs();
    // 构建列表
    return ListView.separated(
      shrinkWrap: true,
      padding: kVer12Hor24,
      itemCount: items.length,
      itemBuilder: (ctx, index) {
        final key = items.keys.elementAt(index);
        return ArrayWidget.create(
          config: items[key] as ConfigBase,
          isVertical: false,
          usePassword: hidePasswords[key],
          onChanged: getChange(key),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
    );
  }

  /// 获取当前选项的配置
  TMap<ConfigBase> getConfigs() {
    final configs = site.commentWidgetConfigs;
    return {...?configs[CommentBase], ...?configs[platform]};
  }

  /// 获取 [key] 对应的 onChange 事件
  ValueChanged<dynamic>? getChange(String key) {
    return key == commentPlatformField ? _fieldChange : null;
  }

  /// 初始化字段
  void initConfig() {
    platform = site.comment.commentPlatform;
  }

  /// 重置字段
  Future<void> resetConfig() async {
    await site.loadThemeCustomConfig();
    setState(initConfig);
  }

  /// 字段变化时调用
  void _fieldChange(dynamic str) {
    final value = CommentPlatform.values.firstWhereOrNull((t) => t.name == str) ?? CommentPlatform.gitalk;
    setState(() => platform = value);
  }
}

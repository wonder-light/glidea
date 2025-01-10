import 'dart:async' show Completer;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx, Trans;
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/render/array.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';

/// 评论设置控件
class CommentSettingWidget extends StatefulWidget {
  const CommentSettingWidget({super.key});

  @override
  State<CommentSettingWidget> createState() => CommentSettingWidgetState();
}

class CommentSettingWidgetState extends State<CommentSettingWidget> {
  static const _showComment = 'showComment';
  static const _commentPlatform = 'commentPlatform';

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 初始化时的任务
  Completer initTask = Completer();

  /// 当前选择的评论平台
  late final platform = site.comment.commentPlatform.obs;

  /// 字段配置
  final configs = <Object, TMap<ConfigBase>>{}.obs;

  @override
  void initState() {
    super.initState();
    initConfig();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initTask.future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget());
        }
        return Obx(() {
          final items = {...?configs.value[CommentBase], ...?configs.value[platform.value]};
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
                onChanged: key == _commentPlatform ? _fieldChange : null,
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Padding(padding: kVerPadding8),
          );
        });
      },
    );
  }

  /// 初始化字段
  Future<void> initConfig() async {
    initTask = Completer();
    final comment = site.comment.toMap()!;
    configs.value = {
      for (var key in CommentPlatform.values)
        key: site.createRenderConfig(
          fields: {for (var item in (comment[key.name] as Map).keys) item: FieldType.input},
          fieldValues: comment[key.name],
        ),
      CommentBase: site.createRenderConfig(
        fields: {_commentPlatform: FieldType.radio, _showComment: FieldType.toggle},
        fieldValues: comment,
        options: {
          _commentPlatform: [
            for (var t in CommentPlatform.values)
              SelectOption()
                ..label = t.name.tr
                ..value = t.name,
          ],
        },
      ),
    };
    initTask.complete(true);
  }

  /// 字段变化时调用
  void _fieldChange(dynamic str) {
    platform.value = CommentPlatform.values.firstWhereOrNull((t) => t.name == str) ?? CommentPlatform.gitalk;
    site.comment.commentPlatform = platform.value;
  }
}

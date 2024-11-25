import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Obx, Trans, Inst, BoolExtension;
import 'package:glidea/components/drawer.dart';
import 'package:glidea/controller/site.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

abstract class DrawerEditor<T> extends StatefulWidget {
  const DrawerEditor({
    super.key,
    required this.entity,
    required this.controller,
    this.onClose,
    this.onSave,
    this.header = '',
    this.showAction = true,
  });

  /// 实体
  final T entity;

  /// 抽屉控制器
  final DraController controller;

  /// 取消
  final VoidCallback? onClose;

  /// 保存
  final VoidCallback? onSave;

  /// 菜单头部
  final String header;

  final bool showAction;

  @override
  DrawerEditorState<T> createState();
}

abstract class DrawerEditorState<T> extends State<DrawerEditor<T>> {
  /// 是否可以保存
  var canSave = false.obs;

  /// 站点控制器
  final siteController = Get.find<SiteController>(tag: SiteController.tag);

  @override
  Widget build(BuildContext context) {
    // 头
    Widget header = buildHeader(context);
    // 内容
    List<Widget> content = buildContent(context);
    // 字段
    Widget widgets = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          ...content,
        ],
      ),
    );
    // 上下两部分
    widgets = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widgets,
        if (widget.showAction) buildActions(context),
      ],
    );
    // 返回控件
    return widgets;
  }

  /// 构建菜单头部
  Widget buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.header.tr, textScaler: const TextScaler.linear(1.2)),
          IconButton(
            onPressed: onClose,
            icon: const Icon(PhosphorIconsRegular.x),
          ),
        ],
      ),
    );
  }

  /// 构建菜单内容
  List<Widget> buildContent(BuildContext context) {
    return [];
  }

  /// 包装字段
  Widget wrapperField({required Widget child, String? name}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(name.tr),
            ),
          child,
        ],
      ),
    );
  }

  /// 构建底部操作按钮
  Widget buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: onClose,
            child: Text('cancel'.tr),
          ),
          Container(width: 8),
          Obx(
            () => FilledButton(
              onPressed: canSave.value ? onSave : null,
              child: Text('save'.tr),
            ),
          ),
        ],
      ),
    );
  }

  /// 关闭或者取消
  void onClose() {
    widget.onClose?.call();
    widget.controller.close();
  }

  /// 保存
  void onSave() {
    if (!canSave.value) return;
    widget.onSave?.call();
    widget.controller.close();
  }
}

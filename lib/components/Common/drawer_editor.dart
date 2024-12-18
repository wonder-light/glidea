import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, Inst, Obx, Trans;
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/lang/base.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

/// 用时在抽屉中使用的编辑器框架
abstract class DrawerEditor<T> extends StatefulWidget {
  const DrawerEditor({
    super.key,
    required this.entity,
    this.controller,
    this.onClose,
    this.onSave,
    this.header = '',
    this.showAction = true,
    this.hideCancel = false,
    this.enabledScroller = true,
  });

  /// 实体
  final T entity;

  /// 抽屉控制器
  final DraController? controller;

  /// 取消
  final VoidCallback? onClose;

  /// 保存
  final ValueSetter<T>? onSave;

  /// 菜单头部
  final String header;

  /// 显示操作按钮
  final bool showAction;

  /// 隐藏取消按钮
  final bool hideCancel;

  /// 启用滚动
  final bool enabledScroller;

  @override
  DrawerEditorState<DrawerEditor<T>> createState();
}

abstract class DrawerEditorState<T extends DrawerEditor> extends State<T> {
  /// 是否可以保存
  var canSave = false.obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 按钮样式
  final actionStyle = const ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size(double.infinity, kButtonHeight)),
  );

  /// 抽屉控制器
  late final DraController controller = widget.controller ?? DraController();

  @override
  Widget build(BuildContext context) {
    // 头
    Widget header = buildHeader(context);
    // 内容
    List<Widget> content = buildContent(context);
    // 字段
    Widget widgets = Container(
      padding: kAllPadding16 + kVerPadding8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          ...content,
        ],
      ),
    );
    // 启用滚动
    if(widget.enabledScroller) {
      widgets = SingleChildScrollView(child: widgets);
    }
    // 上下两部分
    if (widget.showAction) {
      widgets = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: widgets),
          buildActions(context),
        ],
      );
    }
    // 返回控件
    return widgets;
  }

  /// 构建菜单头部
  Widget buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.header.tr, textScaler: const TextScaler.linear(1.2)),
        IconButton(
          onPressed: onClose,
          icon: const Icon(PhosphorIconsRegular.x),
        ),
      ],
    );
  }

  /// 构建菜单内容
  List<Widget> buildContent(BuildContext context) {
    return [];
  }

  /// 包装字段
  Widget wrapperField({required Widget child, String? name}) {
    return Container(
      margin: kTopPadding8 * 2.25,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name != null)
            Padding(
              padding: kTopPadding8.flipped,
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
      padding: kAllPadding16 + kVerPadding8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!widget.hideCancel)
            OutlinedButton(
              style: actionStyle,
              onPressed: onClose,
              child: Text(Tran.cancel.tr),
            ),
          if (!widget.hideCancel) Container(padding: kRightPadding8),
          Obx(
            () => FilledButton(
              style: actionStyle,
              onPressed: canSave.value ? onSave : null,
              child: Text(Tran.save.tr),
            ),
          ),
        ],
      ),
    );
  }

  /// 关闭或者取消
  void onClose() {
    widget.onClose?.call();
    controller.close();
  }

  /// 保存
  void onSave() {
    if (!canSave.value) return;
    //widget.onSave?.call();
    controller.close();
  }
}

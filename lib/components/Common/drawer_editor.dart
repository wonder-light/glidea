import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/controller/site/site.dart';
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

  @override
  DrawerEditorState<DrawerEditor<T>> createState();
}

abstract class DrawerEditorState<T extends DrawerEditor> extends State<T> {
  /// 是否可以保存
  var canSave = false.obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 按钮样式
  static const _actionStyle = ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size(double.infinity, kButtonHeight)),
  );

  /// 抽屉控制器
  late final DraController controller = widget.controller ?? DraController();

  /// 主题数据
  final theme = Theme.of(Get.context!);

  @override
  Widget build(BuildContext context) {
    // 头部
    Widget child = SliverAppBar(
      pinned: true,
      titleSpacing: 0,
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      backgroundColor: theme.drawerTheme.backgroundColor,
      title: Text(widget.header.tr),
      actions: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(PhosphorIconsRegular.x),
        ),
      ],
    );
    // 自定义滚动
    child = CustomScrollView(
      slivers: [
        child,
        const SliverPadding(padding: kTopPadding8),
        // 内容
        SliverList(delegate: SliverChildBuilderDelegate(buildContent)),
        // 底部操作
        if (widget.showAction) const SliverPadding(padding: kTopPadding8),
        if (widget.showAction)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: buildActions(context),
            ),
          ),
      ],
    );
    // 加上内边距
    return Padding(padding: kAllPadding16 + kVerPadding8, child: child);
  }

  /// 构建菜单内容
  Widget? buildContent(BuildContext context, int index) => null;

  /// 构建底部操作按钮
  Widget buildActions(BuildContext context) {
    return Row(
      spacing: kRightPadding8.right,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!widget.hideCancel)
          OutlinedButton(
            style: _actionStyle,
            onPressed: onClose,
            child: Text(Tran.cancel.tr),
          ),
        Obx(
          () => FilledButton(
            style: _actionStyle,
            onPressed: canSave.value ? onSave : null,
            child: Text(Tran.save.tr),
          ),
        ),
      ],
    );
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

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, IntExtension, Obx, Trans;
import 'package:glidea/helpers/constants.dart';

/// 分组布局控件
class GroupWidget extends StatefulWidget {
  const GroupWidget({
    super.key,
    required this.groups,
    required this.itemBuilder,
    this.isTop = false,
    this.isScrollable = true,
    this.allowImplicitScrolling = true,
    this.initialIndex = 0,
    this.itemPadding,
    this.labelPadding,
    this.contentPadding,
    this.tabAlignment = TabAlignment.start,
    this.onTap,
  });

  /// 配置
  final List<String> groups;

  /// 是否是最顶级的标签页
  final bool isTop;

  /// 初始化索引
  final int initialIndex;

  /// 是否可以滚动此选项卡栏
  final bool isScrollable;

  /// 添加到每个制表标签上的填充
  final EdgeInsets? itemPadding;

  /// 整个 Tab 的内容边距
  final EdgeInsets? labelPadding;

  /// 整个 Tab 的内容边距
  final EdgeInsets? contentPadding;

  /// 指定选项卡内选项卡的对齐方式
  final TabAlignment? tabAlignment;

  /// 设置为 true, 缓存一个页面
  ///
  /// 设置为 false, 不缓存页面
  final bool allowImplicitScrolling;

  /// 一个可选的回调在TabBar被点击时被调用
  final ValueChanged<int>? onTap;

  /// 构建子控件
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  State<StatefulWidget> createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  /// 页面控制器
  late final PageController controller = PageController(initialPage: widget.initialIndex);

  /// 当前页面的索引
  late final currentIndex = widget.initialIndex.obs;

  /// 选择时的文字样式
  late final selectStyle = Get.textTheme.bodyMedium!.copyWith(
    color: Get.theme.colorScheme.primary,
  );

  @override
  void dispose() {
    currentIndex.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 主题内容
    Widget content = PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: controller,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      itemCount: widget.groups.length,
      itemBuilder: widget.itemBuilder,
    );
    // 内容边距
    if (widget.contentPadding != null) {
      content = Padding(padding: widget.contentPadding!, child: content);
    }
    // 大体布局
    final layout = widget.isTop ? Column.new : Row.new;
    return layout(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabs(),
        if (widget.isTop)
          const Divider(thickness: 1, height: 1)
        // 垂直线
        else
          const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: content),
      ],
    );
  }

  /// 构建 tabs 中的内容
  Widget _buildTabs() {
    // label 边距
    final labelPadding = widget.itemPadding ?? ((widget.isTop ? kVerPadding16 : kVerPadding8) + kHorPadding8);
    final children = [
      for (var i = 0; i < widget.groups.length; i++)
        InkWell(
          onTap: () {
            currentIndex.value = i;
            controller.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.ease);
            widget.onTap?.call(i);
          },
          child: Container(
            alignment: Alignment.center,
            padding: labelPadding,
            child: Obx(
              () => Text(widget.groups[i].tr, style: currentIndex.value == i ? selectStyle : null),
            ),
          ),
        ),
    ];
    // 布局
    final layout = widget.isTop ? Row.new : Column.new;
    Widget content = layout(
      spacing: kTopPadding8.top,
      mainAxisAlignment: switch (widget.tabAlignment) {
        TabAlignment.fill => MainAxisAlignment.spaceBetween,
        TabAlignment.center => MainAxisAlignment.center,
        _ => MainAxisAlignment.start,
      },
      // 水平时需要居中,垂直时充满次轴
      crossAxisAlignment: widget.isTop ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: children,
    );
    // 整体的边距
    content = Padding(padding: widget.labelPadding ?? kHorPadding16, child: content);
    // Tab 垂直时, 限定宽度
    if (!widget.isTop) {
      content = IntrinsicWidth(stepWidth: 10, child: content);
    }
    // 滚动
    if (widget.isScrollable) {
      content = SingleChildScrollView(
        scrollDirection: widget.isTop ? Axis.horizontal : Axis.vertical,
        padding: widget.isTop ? null : kVerPadding8,
        child: content,
      );
    }
    return content;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show IntExtension, Obx, Trans;
import 'package:glidea/helpers/constants.dart';

/// 分组布局控件
class PageWidget extends StatefulWidget {
  /// [groups.isEmpty] 时不创建 [PageView], 同时 [child] 不能为 null
  ///
  /// [groups.isNotEmpty] 时, [itemBuilder] 不能为 null
  const PageWidget({
    super.key,
    this.groups = const [],
    this.itemBuilder,
    this.child,
    this.actions = const [],
    this.isTop = true,
    this.isScrollable = true,
    this.allowImplicitScrolling = true,
    this.initialIndex = 0,
    this.itemPadding,
    this.labelPadding,
    this.contentPadding,
    this.toolbarPadding,
    this.tabAlignment = TabAlignment.start,
    this.onTap,
  });

  /// 配置
  final List<String> groups;

  /// 后面的操作按钮
  final List<Widget> actions;

  /// 分割线下的内容控件
  final Widget? child;

  /// 是否是最顶级的标签页
  final bool isTop;

  /// 初始化索引
  final int initialIndex;

  /// 是否可以滚动此选项卡栏
  final bool isScrollable;

  /// 添加到每个制表标签上的填充
  final EdgeInsetsGeometry? itemPadding;

  /// 整个 Tabs 的内容边距
  final EdgeInsetsGeometry? labelPadding;

  /// 整个内容的内容边距
  final EdgeInsetsGeometry? contentPadding;

  /// 工具栏的内边距, 默认是 [kAllPadding8]
  final EdgeInsetsGeometry? toolbarPadding;

  /// 指定选项卡内选项卡的对齐方式
  final TabAlignment? tabAlignment;

  /// 设置为 true, 缓存一个页面
  ///
  /// 设置为 false, 不缓存页面
  final bool allowImplicitScrolling;

  /// 一个可选的回调在TabBar被点击时被调用
  final ValueChanged<int>? onTap;

  /// 构建子控件
  final NullableIndexedWidgetBuilder? itemBuilder;

  @override
  State<StatefulWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  /// 页面控制器
  late final PageController? controller = isGroup ? PageController(initialPage: widget.initialIndex) : null;

  /// 当前页面的索引
  late final currentIndex = isGroup ? widget.initialIndex.obs : null;

  /// 主题样式
  late final theme = Theme.of(context);

  /// 选择时的文字样式
  late final selectStyle = theme.textTheme.bodyMedium!.copyWith(
    color: theme.colorScheme.primary,
  );

  /// 是否使用 Group
  bool get isGroup => widget.groups.isNotEmpty;

  @override
  void dispose() {
    currentIndex?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 主题内容
    Widget content = isGroup
        ? PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            allowImplicitScrolling: widget.allowImplicitScrolling,
            itemCount: widget.groups.length,
            itemBuilder: widget.itemBuilder!,
          )
        : widget.child!;

    // 内容边距
    if (widget.contentPadding != null) {
      content = Padding(padding: widget.contentPadding!, child: content);
    }
    // 大体布局
    final isColumn = !isGroup || widget.isTop;
    final layout = isColumn ? Column.new : Row.new;
    content = layout(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBar(),
        if (isColumn)
          const Divider(thickness: 1, height: 1)
        // 垂直线
        else
          const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: content),
      ],
    );
    // 添加 Material
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: content,
    );
  }

  /// 构建 AppBar
  Widget _buildBar() {
    // actions
    Widget toolbar = Padding(
      padding: widget.toolbarPadding ?? (kAllPadding8 + kRightPadding8),
      child: Row(
        spacing: kRightPadding8.right,
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.actions,
      ),
    );
    if (!isGroup) return toolbar;
    // tab + toolbar
    Widget content = _buildTabs();
    // 添加 actions
    if (widget.isTop && widget.actions.isNotEmpty) {
      content = Row(
        children: [Expanded(child: content), toolbar],
      );
    }
    return content;
  }

  /// 构建 tabs 中的内容
  Widget _buildTabs() {
    // label 边距
    final labelPadding = widget.itemPadding ?? ((widget.isTop ? kVerPadding16 : kVerPadding8) + kHorPadding8);
    final children = [
      for (var i = 0; i < widget.groups.length; i++)
        InkWell(
          onTap: () {
            currentIndex?.value = i;
            controller?.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.ease);
            widget.onTap?.call(i);
          },
          child: Container(
            alignment: Alignment.center,
            padding: labelPadding,
            child: Obx(
              () => Text(widget.groups[i].tr, style: currentIndex?.value == i ? selectStyle : null),
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

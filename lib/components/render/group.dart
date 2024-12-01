import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;

/// 分组布局控件
class GroupWidget extends StatelessWidget {
  const GroupWidget({
    super.key,
    required this.children,
    required this.groups,
    this.isTop = false,
    this.isScroll = false,
    this.isScrollable = false,
    this.initialIndex = 0,
    this.labelPadding,
    this.tabAlignment = TabAlignment.start,
    this.onTap,
  });

  /// 配置
  final Set<String> groups;

  /// 子节点
  final List<Widget> children;

  /// 是否是最顶级的标签页
  final bool isTop;

  /// 初始化索引
  final int initialIndex;

  /// 是否可以水平滚动此选项卡栏
  final bool isScrollable;

  /// 内容是否可以垂直滚动
  final bool isScroll;

  /// 添加到每个制表标签上的填充
  final EdgeInsets? labelPadding;

  /// 指定选项卡内选项卡的对齐方式
  final TabAlignment? tabAlignment;

  /// 一个可选的回调在TabBar被点击时被调用
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    // Tab
    Widget childWidget = TabBar.secondary(
      isScrollable: isScrollable,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      labelPadding: labelPadding ?? EdgeInsets.symmetric(horizontal: isTop ? 24 : 6, vertical: isTop ? 0 : 32),
      tabAlignment: tabAlignment,
      onTap: onTap,
      tabs: [
        for (var item in groups)
          if (isTop)
            Tab(text: item.tr)
          else
            RotatedBox(
              quarterTurns: 1,
              child: Tab(text: item.tr),
            ),
      ],
    );
    // 内容
    Widget content = Expanded(
      child: TabBarView(children: [
        for (var child in children)
          if (isScroll)
            SingleChildScrollView(
              child: child,
            )
          else
            child,
      ]),
    );

    if (!isTop) {
      // 左边垂直 Tab
      childWidget = Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          RotatedBox(quarterTurns: -1, child: childWidget),
          content,
        ],
      );
    } else {
      // 顶部 Tab
      childWidget = Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          childWidget,
          content,
        ],
      );
    }

    // 加控制器
    childWidget = DefaultTabController(
      length: groups.length,
      initialIndex: initialIndex,
      child: childWidget,
    );
    // 返回
    return childWidget;
  }
}

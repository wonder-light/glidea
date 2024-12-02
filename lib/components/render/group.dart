import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/helpers/constants.dart';

/// 分组布局控件
class GroupWidget extends StatelessWidget {
  const GroupWidget({
    super.key,
    required this.children,
    required this.groups,
    this.isTop = false,
    this.isScrollable = true,
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

  /// 添加到每个制表标签上的填充
  final EdgeInsets? labelPadding;

  /// 指定选项卡内选项卡的对齐方式
  final TabAlignment? tabAlignment;

  /// 一个可选的回调在TabBar被点击时被调用
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    // 加控制器返回
    return DefaultTabController(
      length: groups.length,
      initialIndex: initialIndex,
      child: _buildContent(
        child: TabBar.secondary(
          isScrollable: isScrollable,
          // 整个 tabs 的边距
          padding: kHorPadding16,
          labelPadding: labelPadding ?? (isTop ? kHorPadding16 : kVer24Hor16),
          tabAlignment: tabAlignment,
          onTap: onTap,
          tabs: _buildTabs(),
        ),
        content: Expanded(
          child: TabBarView(children: children),
        ),
      ),
    );
  }

  /// 构建 tabs 中的内容
  List<Widget> _buildTabs() {
    // 横着的 tabs
    if (isTop) {
      return groups.map((t) => Tab(text: t.tr)).toList();
    }
    // 约束
    var constraints = const BoxConstraints(
      minHeight: 30,
      maxHeight: 90,
    );
    // 竖着的 tabs
    return [
      for (var item in groups)
        Container(
          constraints: constraints,
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: 1,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(pi),
              child: Text(item.tr),
            ),
          ),
        ),
    ];
  }

  /// 构建整个框架
  Widget _buildContent({required Widget child, required Widget content}) {
    if (isTop) {
      // 顶部 Tab
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          child,
          content,
        ],
      );
    }

    // 左边垂直 Tab
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        RotatedBox(
          quarterTurns: -1,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: child,
          ),
        ),
        content,
      ],
    );
  }

  /// 获取文字大小
  Size getTextSize(String text, [TextStyle? style]) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    painter.layout();
    return painter.size;
  }
}

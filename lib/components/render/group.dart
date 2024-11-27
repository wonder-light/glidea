import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glidea/models/render.dart';

/// 分组布局控件
class GroupWidget extends StatelessWidget {
  const GroupWidget({
    super.key,
    required this.configs,
    this.isTop = false,
  });

  /// 配置
  final List<ConfigBase> configs;

  /// 是否是最顶级的标签页
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    Set<String> groups = configs.map((t) => t.group).toSet();
    // Tab
    Widget childWidget = TabBar.secondary(
      isScrollable: !isTop,
      tabs: [
        for (var item in groups)
          if (isTop)
            Tab(text: item)
          else
            RotatedBox(
              quarterTurns: 1,
              child: Tab(text: item),
            ),
      ],
    );
    // 内容
    Widget content = Expanded(
      child: TabBarView(
        children: [
          for (var item in groups)
            Container(
              color: Colors.accents[Random().nextInt(10)],
            ),
        ],
      ),
    );

    if (!isTop) {
      // 左边垂直 Tab
      childWidget = Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RotatedBox(quarterTurns: -1, child: childWidget),
            ],
          ),
          content,
        ],
      );
    } else {
      // 顶部 Tab
      childWidget = Column(
        children: [
          childWidget,
          content,
        ],
      );
    }

    // 加控制器
    childWidget = DefaultTabController(
      length: groups.length,
      child: childWidget,
    );
    // 返回
    return childWidget;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;

class PageAction extends StatelessWidget {
  const PageAction({
    super.key,
    required this.child,
    this.leading,
    this.actions = const [],
  });

  /// 前面的操作控件
  final Widget? leading;

  /// 后面的操作按钮
  final List<Widget> actions;

  /// 分割线下的内容控件
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 操作列表
    List<Widget> actionList = [
      for (var item in actions)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: item,
        ),
    ];
    // 头部
    Widget childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: leading,
        ),
        Row(
          children: actionList,
        ),
      ],
    );
    // 加上分割线, 以及内容
    childWidget = Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 8),
            child: childWidget,
          ),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
    // 返回控件
    return childWidget;
  }
}

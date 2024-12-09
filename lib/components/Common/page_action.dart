import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;
import 'package:glidea/helpers/constants.dart';

/// 菜单和标签页面的公共部分
class PageAction extends StatelessWidget {
  const PageAction({
    super.key,
    required this.child,
    this.leading,
    this.actions = const [],
    this.contentPadding
  });

  /// 前面的操作控件
  final Widget? leading;

  /// 后面的操作按钮
  final List<Widget> actions;

  /// 分割线下的内容控件
  final Widget child;

  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    // 操作列表
    List<Widget> actionList = [
      for (var item in actions)
        Padding(
          padding: kRightPadding8,
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
    // 使用 [Material] 在切换路由时可以将背景变不透明, 不至于让两个页面看起来重叠在了一起
    childWidget = Material(
      color: Get.theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: kAllPadding16.copyWith(bottom: 8),
            child: childWidget,
          ),
          const Divider(thickness: 1, height: 1),
          Expanded(
            child: Padding(
              padding: contentPadding ?? kAllPadding16,
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

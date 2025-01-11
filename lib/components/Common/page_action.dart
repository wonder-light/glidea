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
    this.contentPadding,
  });

  /// 前面的操作控件
  final Widget? leading;

  /// 后面的操作按钮
  final List<Widget> actions;

  /// 分割线下的内容控件
  final Widget child;

  /// 内容的内边距, 默认是 [kAllPadding16]
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    // 操作
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var item in actions) Padding(padding: kRightPadding8, child: item),
      ],
    );
    // 标题
    if (leading != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [leading!, content],
      );
    }
    // 加上分割线, 以及内容
    // 使用 [Material] 在切换路由时可以将背景变不透明, 不至于让两个页面看起来重叠在了一起
    final bgColor = Theme.of(Get.context!).scaffoldBackgroundColor;
    // 返回控件
    return Material(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
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
  }
}

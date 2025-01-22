import 'package:flutter/material.dart';
import 'package:glidea/helpers/constants.dart';

/// 菜单和标签页面的公共部分
class PageAction extends StatelessWidget {
  const PageAction({
    super.key,
    required this.child,
    this.leading,
    this.actions = const [],
    this.contentPadding = kAllPadding16,
    this.toolbarPadding = kAllPadding8,
  });

  /// 前面的操作控件
  final Widget? leading;

  /// 后面的操作按钮
  final List<Widget> actions;

  /// 分割线下的内容控件
  final Widget child;

  /// 内容的内边距, 默认是 [kAllPadding16]
  final EdgeInsetsGeometry contentPadding;

  /// 工具栏的内边距, 默认是 [kAllPadding8]
  final EdgeInsetsGeometry toolbarPadding;

  @override
  Widget build(BuildContext context) {
    // 操作
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 标题
        if (leading != null) Flexible(child: leading!),
        for (var item in actions) Padding(padding: kRightPadding8, child: item),
      ],
    );
    // 加上分割线, 以及内容
    // 使用 [Material] 在切换路由时可以将背景变不透明, 不至于让两个页面看起来重叠在了一起
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    // 返回控件
    return Material(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(padding: toolbarPadding, color: bgColor, child: content),
          const Divider(thickness: 1, height: 1),
          Expanded(child: Padding(padding: contentPadding, child: child)),
        ],
      ),
    );
  }
}

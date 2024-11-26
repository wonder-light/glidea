import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense,
    this.shape,
    this.contentPadding,
    this.enabled = true,
    this.selected = false,
    this.tileColor,
    this.selectedTileColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.constraints,
  });

  ///列表平铺的主要内容
  final Widget? title;

  ///标题下方显示的附加内容
  final Widget? subtitle;

  /// 在标题之前显示的小部件
  final Widget? leading;

  /// 标题后显示的小部件
  final Widget? trailing;

  /// 当用户点击这个列表平铺时调用
  ///
  /// 如果 [enabled] 为 false 则无效
  final GestureTapCallback? onTap;

  /// 此列表平铺是否为垂直密集列表的一部分
  final bool? dense;

  ///定义贴图的 [InkWell.customBorder] 和 [Ink.decoration] 的形状。
  final ShapeBorder? shape;

  /// 组件的内部填充
  ///
  /// 默认:
  ///
  ///     EdgeInsets.symmetric(vertical: 16)
  final EdgeInsetsGeometry? contentPadding;

  /// 此列表平铺是否交互式
  final bool enabled;

  /// 如果此平铺也 [enabled]，则图标和文本以相同的颜色呈现
  final bool selected;

  /// 当 [selected] 为 false 时，定义 ListTile 的背景颜色
  final Color? tileColor;

  /// 当 [selected] 为 true 时，定义 ListTile 的背景颜色
  final Color? selectedTileColor;

  /// [ListItem] 的 [title] 的文本样式
  final TextStyle? titleTextStyle;

  /// [ListItem] 的 [subtitle] 的文本样式
  final TextStyle? subtitleTextStyle;

  /// [ListItem] 的 宽高约束
  ///
  /// 默认:
  ///
  ///     BoxConstraints(minHeight: 80, maxHeight: 150)
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    // 主题配置
    final theme = Get.theme;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final ListTileThemeData defaults = theme.listTileTheme;

    Widget childWidget = Container(
      padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      constraints: constraints ?? const BoxConstraints(minHeight: 80, maxHeight: 150),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (leading != null)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: leading!,
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    AnimatedDefaultTextStyle(
                      style: titleTextStyle ?? textTheme.bodyLarge!.apply(fontSizeFactor: 1.2),
                      duration: kThemeChangeDuration,
                      child: title!,
                    ),
                  if (subtitle != null)
                    AnimatedDefaultTextStyle(
                      style: subtitleTextStyle ?? textTheme.bodySmall!,
                      duration: kThemeChangeDuration,
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: trailing!,
              ),
          ],
        ),
      ),
    );

    childWidget = InkWell(
      customBorder: shape ?? defaults.shape,
      onTap: enabled ? onTap : null,
      enableFeedback: enabled,
      child: Semantics(
        selected: selected,
        enabled: enabled,
        child: Ink(
          decoration: ShapeDecoration(
            shape: shape ?? const Border(),
            color: selected ? selectedTileColor ?? defaults.selectedTileColor ?? colorScheme.primary : tileColor ?? defaults.tileColor ?? Colors.transparent,
          ),
          child: childWidget,
        ),
      ),
    );
    return childWidget;
  }
}

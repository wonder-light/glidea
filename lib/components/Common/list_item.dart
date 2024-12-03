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
    this.dense = false,
    this.shape,
    this.contentPadding,
    this.enabled = true,
    this.selected = false,
    this.tileColor,
    this.selectedTileColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.constraints,
    this.leadingMargin,
    this.trailingMargin,
    this.selectedColor,
    this.leadingAndTrailingTextStyle,
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
  final bool dense;

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

  /// 定义选择列表平铺时图标和文本使用的颜色
  final Color? selectedColor;

  /// 当 [selected] 为 false 时，定义 ListTile 的背景颜色
  final Color? tileColor;

  /// 当 [selected] 为 true 时，定义 ListTile 的背景颜色
  final Color? selectedTileColor;

  /// [ListItem] 的 [title] 的文本样式
  final TextStyle? titleTextStyle;

  /// [ListItem] 的 [subtitle] 的文本样式
  final TextStyle? subtitleTextStyle;

  /// [ListItem] 的 [leading] 和 [trailing] 的文本样式
  final TextStyle? leadingAndTrailingTextStyle;

  /// [ListItem] 的宽高约束
  ///
  /// 默认:
  ///
  ///     BoxConstraints(minHeight: 80, maxHeight: 150)
  final BoxConstraints? constraints;

  /// [leading] 的外边距
  ///
  /// 默认:
  ///
  ///     EdgeInsets.only(right: 16)
  final EdgeInsetsGeometry? leadingMargin;

  /// [trailing] 的外边距
  ///
  /// 默认:
  ///
  ///     EdgeInsets.only(left: 16)
  final EdgeInsetsGeometry? trailingMargin;

  @override
  Widget build(BuildContext context) {
    // 主题配置
    final theme = Get.theme;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final ListTileThemeData defaults = theme.listTileTheme;
    // 标题样式
    var titleStyle = titleTextStyle ?? (dense ? textTheme.bodyMedium! : textTheme.bodyLarge!.apply(fontSizeFactor: 1.2));
    if (selected) {
      titleStyle = titleStyle.copyWith(color: selectedColor);
    }
    // 子标题样式
    var subtitleStyle = subtitleTextStyle ?? textTheme.bodySmall!;
    if (selected) {
      subtitleStyle = subtitleStyle.copyWith(color: selectedColor);
    }
    // [leading] And [trailing] 样式
    var leadingAndTrailingStyle = leadingAndTrailingTextStyle ?? defaults.leadingAndTrailingTextStyle ?? textTheme.bodyMedium!;
    if (selected) {
      leadingAndTrailingStyle = leadingAndTrailingStyle.copyWith(color: selectedColor);
    }
    // 图标样式
    var iconTheme = theme.iconTheme;
    if (selected) {
      iconTheme = iconTheme.copyWith(color: selectedColor);
    }
    // 构建 [leading] And [trailing]
    Widget buildLeadingAndTrailing(Widget child, {bool isLeading = true}) {
      return Container(
        margin: leadingMargin ?? (isLeading ? EdgeInsets.only(right: dense ? 10 : 16) : EdgeInsets.only(left: dense ? 10 : 16)),
        child: AnimatedDefaultTextStyle(
          style: leadingAndTrailingStyle,
          duration: kThemeChangeDuration,
          child: IconTheme(
            data: iconTheme,
            child: child,
          ),
        ),
      );
    }
    // 子控件内容
    Widget childWidget = Container(
      padding: contentPadding ?? EdgeInsets.symmetric(vertical: dense ? 10 : 16, horizontal: dense ? 10 : 12),
      constraints: constraints ?? BoxConstraints(minHeight: dense ? 40 : 80, maxHeight: dense ? 70 : 150),
      child: Row(
        children: [
          if (leading != null) buildLeadingAndTrailing(leading!, isLeading: true),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  AnimatedDefaultTextStyle(
                    style: titleStyle,
                    duration: kThemeChangeDuration,
                    child: title!,
                  ),
                if (subtitle != null)
                  AnimatedDefaultTextStyle(
                    style: subtitleStyle,
                    duration: kThemeChangeDuration,
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          if (trailing != null) buildLeadingAndTrailing(trailing!, isLeading: false),
        ],
      ),
    );
    // 子控件装饰
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

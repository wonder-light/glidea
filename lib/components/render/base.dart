import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/render.dart';

abstract class ConfigBaseWidget<T extends ConfigBase> extends StatelessWidget {
  const ConfigBaseWidget({
    super.key,
    required this.config,
    this.isTop = true,
    this.ratio = 2.0,
    this.labelPadding,
    this.contentPadding,
    this.helperPadding,
    this.onChanged,
  });

  /// true: 标题在顶部
  ///
  /// false: 标题在前面
  final bool isTop;

  /// [isTop] = [true] 时启用
  ///
  /// 比率: ratio = select / text
  final double ratio;

  /// 下拉列表配置
  ///
  /// [config.label] 需要手动添加 [i18n] 翻译
  final RxObject<T> config;

  /// 标签的边距
  ///
  ///     if(isTop = true) labelPadding = EdgeInsets.symmetric(vertical: 8)
  ///     else labelPadding = EdgeInsets.only(right: 16)
  final EdgeInsetsGeometry? labelPadding;

  /// 内容边距, 包裹所有控件的边距
  final EdgeInsetsGeometry? contentPadding;

  /// 左下角的提示文本边距
  ///
  /// 默认:
  ///
  ///     EdgeInsets.symmetric(horizontal: 12, vertical: 4)
  final EdgeInsetsGeometry? helperPadding;

  /// 当值发生变化时调用 - 主要用于 ArrayWidget 中接收值的变化
  final ValueChanged<dynamic>? onChanged;

  @override
  Widget build(BuildContext context) {
    const base = 100;
    var theme = Get.theme;
    Widget childWidget = buildContent(context, theme);
    // 标签
    Widget label = Padding(
      padding: labelPadding ?? (isTop ? kVerPadding8 : kRightPadding16),
      child: Text(config.value.label.tr),
    );
    // 提示
    Widget? note;
    if (config.value.note.isNotEmpty) {
      note = Padding(
        padding: helperPadding ?? kVerPadding4,
        child: Text(
          config.value.note.tr,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }
    // 垂直方向
    if (isTop) {
      childWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [label, childWidget, if (note != null) note],
      );
    } else {
      // 比率
      var value = (ratio * base).ceil();
      // 给水平的方式添加包装
      label = Flexible(flex: base, child: label);
      // 将内容不能缩放的对齐在左边开始的位置
      childWidget = Expanded(
        flex: value,
        child: Align(
          alignment: Alignment.centerLeft,
          child: childWidget,
        ),
      );
      // 空状态
      Widget empty = Flexible(flex: base, child: Container());
      if (note != null) {
        note = Flexible(flex: base + value, child: note);
      }
      // 控件的第一行
      childWidget = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [label, childWidget, empty],
      );
      if (note != null) {
        // 提示文本的第二行
        childWidget = Column(
          children: [
            childWidget,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [empty, note],
            )
          ],
        );
      }
    }

    // 内容边距, 包裹所有控件的边距
    if (contentPadding != null) childWidget = Padding(padding: contentPadding!, child: childWidget);

    return childWidget;
  }

  /// 构建内容
  Widget buildContent(BuildContext context, ThemeData theme);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/render.dart';

abstract class ConfigBaseWidget<T extends ConfigBase> extends StatelessWidget {
  const ConfigBaseWidget({
    super.key,
    required this.config,
    this.isVertical = true,
    this.onChanged,
  });

  /// true: 标题在顶部
  ///
  /// false: 标题在前面
  final bool isVertical;

  /// 下拉列表配置
  ///
  /// [config.label] 需要手动添加 [i18n] 翻译
  final RxObject<T> config;

  /// 当值发生变化时调用 - 主要用于 ArrayWidget 中接收值的变化
  final ValueChanged<dynamic>? onChanged;
}

class ConfigLayoutWidget extends StatelessWidget {
  const ConfigLayoutWidget({
    super.key,
    required this.config,
    required this.child,
    this.isVertical = true,
    this.ratio = 2.0,
    this.labelPadding,
    this.contentPadding,
    this.helperPadding,
  });

  /// true: 标题在顶部
  ///
  /// false: 标题在前面
  final bool isVertical;

  /// [isTop] = [true] 时启用
  ///
  /// 比率: ratio = select / text
  final double ratio;

  /// 下拉列表配置
  ///
  /// [config.label] 需要手动添加 [i18n] 翻译
  final ConfigBase config;

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

  /// 子节点控件
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget childWidget = _buildContent(
      child: child,
      label: _buildLabel(),
      note: _buildNote(),
    );

    // 内容边距, 包裹所有控件的边距
    if (contentPadding != null) {
      childWidget = Padding(padding: contentPadding!, child: childWidget);
    }

    return childWidget;
  }

  /// 构建标签
  Widget? _buildLabel() {
    // 如果是空的则返回 null
    if (config.label.isEmpty) return null;
    // 返回标签
    return Padding(
      padding: labelPadding ?? (isVertical ? kVerPadding8 : kVer8Hor12),
      child: Text(config.label.tr),
    );
  }

  /// 构建提示
  Widget? _buildNote() {
    // 如果是空的则返回 null
    if (config.note.isEmpty) return null;
    // 主题
    var theme = Get.theme;
    // 返回提示
    return Padding(
      padding: helperPadding ?? kVerPadding4,
      child: Text(
        config.note.tr,
        style: theme.textTheme.bodySmall!.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  /// 构建内容
  Widget _buildContent({required Widget child, Widget? label, Widget? note}) {
    if (isVertical) {
      // 垂直布局
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) label,
          child,
          if (note != null) note,
        ],
      );
    }
    // 基础比例
    const base = 100;
    // child 的比例
    final value = (ratio * base).ceil();
    // 加入提示
    if (note != null) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          note,
        ],
      );
    } else {
      // 对齐
      child = Align(
        alignment: Alignment.centerLeft,
        child: child,
      );
    }
    // 水平布局
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(flex: base, child: label ?? Container()),
        Expanded(flex: value, child: child),
        Flexible(flex: base, child: Container()),
      ],
    );
  }
}

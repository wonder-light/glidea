import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glidea/helpers/constants.dart';

/// [Autocomplete] 控件的包装
class AutocompleteField<T extends Object> extends StatelessWidget {
  const AutocompleteField({
    super.key,
    required this.optionsBuilder,
    this.displayStringForOption,
    this.onSelected,
    this.optionsViewBuilder,
    this.fieldViewBuilder,
    this.controller,
    this.onChanged,
    this.inputFormatters,
  }) : fieldKey = const GlobalObjectKey({});

  /// 返回选择选项时要在字段中显示的字符串。
  final AutocompleteOptionToString<T>? displayStringForOption;

  /// 返回给定的当前可选择选项对象的函数
  final AutocompleteOptionsBuilder<T> optionsBuilder;

  /// 选中时的回调
  final AutocompleteOnSelected<T>? onSelected;

  /// 弹出选项的构建函数
  final AutocompleteOptionsViewBuilder<T>? optionsViewBuilder;

  /// 字段视图的构建函数
  final AutocompleteFieldViewBuilder? fieldViewBuilder;

  /// 字段控制器
  final TextEditingController? controller;

  /// 字段内容变化时的回调
  final ValueChanged<String>? onChanged;

  /// 字段的格式化
  final List<TextInputFormatter>? inputFormatters;

  /// 字段的全局键
  final GlobalKey fieldKey;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      displayStringForOption: displayStringForOption ?? RawAutocomplete.defaultStringForOption,
      optionsBuilder: optionsBuilder,
      onSelected: onSelected,
      optionsViewBuilder: _buildOptionsView,
      fieldViewBuilder: fieldViewBuilder ?? _viewBuilder,
    );
  }

  /// 构建列表选项组件
  Widget _buildOptionsView(BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
    // 获取链接字段的宽度
    final maxWidth = fieldKey.currentContext?.findRenderObject()?.semanticBounds.width ?? double.infinity;
    // 子控件
    Widget childWidget = optionsViewBuilder?.call(context, onSelected, options) ?? Container();

    // 返回控件
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 10,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 260,
            maxWidth: maxWidth,
          ),
          child: childWidget,
        ),
      ),
    );
  }

  /// 构建字段组件
  ///
  /// (?<=Expression)逆序肯定环视，表示所在位置左侧能够匹配Expression
  ///
  /// (?<!Expression)逆序否定环视，表示所在位置左侧不能匹配Expression
  ///
  /// (?=Expression)顺序肯定环视，表示所在位置右侧能够匹配Expression
  ///
  /// (?!Expression)顺序否定环视，表示所在位置右侧不能匹配Expression
  ///
  /// see https://www.zhihu.com/question/21015580
  Widget _viewBuilder(BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
    // 设置初始值
    if (controller != null && textEditingController.text.isEmpty) {
      textEditingController.text = controller!.text;
    }

    return TextFormField(
      key: fieldKey,
      focusNode: focusNode,
      controller: textEditingController,
      onFieldSubmitted: (_) => onFieldSubmitted(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
      ),
      onChanged: _onChanged,
      inputFormatters: inputFormatters,
    );
  }

  void _onChanged(String str) {
    if (controller != null) {
      controller!.text = str;
    }
    onChanged?.call(str);
  }
}

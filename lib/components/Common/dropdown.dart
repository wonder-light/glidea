import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, TextInputFormatter;
import 'package:get/get.dart' show BoolExtension, DoubleExtension, Get, GetNavigationExt, IntExtension, Obx, StringExtension;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';

/// 下拉按钮菜单
class DropdownWidget<T> extends StatefulWidget {
  /// Creates a const [DropdownWidget].
  const DropdownWidget({
    super.key,
    this.enabled = true,
    this.initValue,
    this.width,
    this.itemHeight = _itemHeight,
    this.itemsMaxHeight = _itemsMaxHeight,
    this.itemPadding,
    this.selectedTrailingIcon,
    this.enableFilter = false,
    this.enableSearch = false,
    this.enableHighlight = false,
    this.filterCallback,
    this.highlightBuild,
    this.headerItem,
    this.bottomItem,
    this.textController,
    required this.children,
    this.displayStringForItem = _defaultDisplayStringForItem<dynamic>,
    this.onSelected,
    this.decoration,
    this.inputFormatters,
  });

  /// 确定是否启用了 [DropdownWidget]
  final bool enabled;

  /// 初始值
  ///
  /// 如果为 null, 则默认选择第一项
  final T? initValue;

  /// 确定 [DropdownWidget] 的宽度
  ///
  /// 如果该值为空，则 [DropdownWidget] 的宽度将与最宽的宽度相同菜单项加上前后图标的宽度.
  final double? width;

  /// 确定 [DropdownWidget] 中 [children] 的最大高度
  final double? itemsMaxHeight;

  /// 确定菜单的高度.
  ///
  /// 如果该值为空，则菜单将在屏幕上显示尽可能多的项目.
  final double? itemHeight;

  /// 菜单的边距
  ///
  /// 如果该值为空，则不使用 [Padding]
  final EdgeInsetsGeometry? itemPadding;

  /// 确定是否可以通过文本输入筛选菜单列表
  ///
  /// 默认 false
  final bool enableFilter;

  /// 启用搜索
  ///
  /// 如果为 true, 则 [TextField] 是可输入状态, 否则是只读状态
  final bool enableSearch;

  /// 启用选择 [item] 的高亮
  final bool enableHighlight;
  /// [enableFilter] 为 true 时需要设置
  final TFilterCallback<T>? filterCallback;

  /// item 转字符串的函数
  final TDisplayStringForItem<T> displayStringForItem;

  /// [item] 的高亮自定义构建函数
  final TChangeValue<Widget>? highlightBuild;
  /// 在弹出菜单顶部显示的控件
  final DropdownMenuItem<T>? headerItem;

  /// 在弹出菜单底部显示的控件
  final DropdownMenuItem<T>? bottomItem;

  /// [DropdownWidget]中菜单项的描述
  final List<DropdownMenuItem<T>> children;

  /// 当用户选择一项时调用
  final ValueChanged<T>? onSelected;

  /// 文本字段末尾的可选图标，用于指示按下文本字段
  ///
  /// 默认为带有 [Icons.arrow_drop_up] 的 [Icon]
  final Widget? selectedTrailingIcon;

  final TextEditingController? textController;

  /// 装饰器
  ///
  /// 默认为 null
  final InputDecoration? decoration;

  /// 创建一个包含TextField的FormField
  final List<TextInputFormatter>? inputFormatters;

  /// 默认的 item 高度
  static const double _itemHeight = 40;

  /// [children] 的 [ListView] 的最大高度
  static const double _itemsMaxHeight = 300;

  /// item 转字符串的默认函数
  static String _defaultDisplayStringForItem<T>(T item) => item.toString();

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  /// 菜单宽度
  final _maxWidth = 350.0.obs;

  /// 判断菜单是否打开
  final _isOpen = false.obs;

  /// [TextFormField] 中的文本内容
  final _textField = ''.obs;

  /// [widget.children] 的数量
  final _itemsNum = 0.obs;

  /// 选择的 item
  final _selectItems = <T>{}.obs;

  /// 主题
  ThemeData get theme => Get.theme;

  /// 菜单控制器
  MenuController menuController = MenuController();

  /// 文本控制器
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    assert(widget.children.every((t) => t.value != null), 'DropdownButton 中有 child 的 value 为 null');
    assert(widget.initValue == null || widget.children.any((t) => t.value == widget.initValue), 'initValue 不在 children 中');
    _updateTextEditor();
  }

  @override
  void dispose() {
    _isOpen.dispose();
    _maxWidth.dispose();
    _itemsNum.dispose();
    _textField.dispose();
    _selectItems.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 子控件
    final List<Widget> children = [];
    // 未启用
    if (!widget.enabled) {
      return _buildAction(
        child: _buildAnchor(
          children: children,
        ),
      );
    }
    // 在弹出菜单顶部显示的控件
    if (widget.headerItem != null) {
      children.add(_buildItemInk(child: widget.headerItem!, other: true));
    }
    // 内容
    if (widget.children.isNotEmpty) {
      children.add(_buildListSized(child: _buildItems()));
    }
    // 在弹出菜单底部显示的控件
    if (widget.bottomItem != null) {
      children.add(_buildItemInk(child: widget.bottomItem!, other: true));
    }
    // 返回
    return _buildAction(
      child: _buildAnchor(
        children: children,
      ),
    );
  }

  /// 构建 [widget.children] 的 [ListView]
  Widget _buildItems() {
    return Obx(() {
      var items = widget.children;
      var text = _textField.value;
      if (widget.filterCallback != null) {
        items = items.where((t) => widget.filterCallback!(t.value as T, text)).toList();
      }
      // list 构建 children
      return ListView.builder(
        shrinkWrap: true,
        itemExtent: widget.itemHeight,
        itemBuilder: (BuildContext context, int index) => _buildItemInk(child: items[index]),
        itemCount: _itemsNum.value = items.length,
      );
    });
  }

  /// 构建 [widget.children] 的 [Ink] 部分
  Widget _buildItemInk({required DropdownMenuItem<T> child, bool other = false}) {
    GestureTapCallback? onTap;
    Widget? item;
    // 启用
    if (child.enabled) {
      onTap = () => _selectItem(child: child, other: other);
      // 对选择的 item 进行高亮
      if (widget.enableHighlight) {
        item = Obx(() {
          if (!_selectItems.value.contains(child.value)) {
            return child;
          }
          return widget.highlightBuild?.call(child) ??
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Expanded(child: child), const Icon(PhosphorIconsRegular.check)],
              );
        });
      }
    } else {
      // 禁用
      final colorScheme = theme.colorScheme;
      item = DefaultTextStyle.merge(
        style: TextStyle(color: colorScheme.outline),
        child: ColoredBox(
          color: colorScheme.surfaceDim,
          child: child,
        ),
      );
    }
    // 边距
    if (widget.itemPadding != null) {
      item = Padding(
        padding: widget.itemPadding!,
        child: item ?? child,
      );
    }
    // 创建一个墨水井
    return Ink(
      height: widget.itemHeight,
      child: InkWell(
        canRequestFocus: child.enabled,
        onTap: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: item,
        ),
      ),
    );
  }

  /// 设置 [ListView] 的宽高
  Widget _buildListSized({required Widget child}) {
    return Obx(() {
      final width = widget.width ?? _maxWidth.value;
      final itemHeight = widget.itemHeight ?? DropdownWidget._itemHeight;
      final maxHeight = widget.itemsMaxHeight ?? DropdownWidget._itemsMaxHeight;
      var height = itemHeight * _itemsNum.value;
      if (height > maxHeight) height = maxHeight;
      return SizedBox(
        width: width,
        height: height,
        child: child,
      );
    });
  }

  /// 构建 [MenuAnchor]
  Widget _buildAnchor({required List<Widget> children}) {
    // 创建一个常量菜单锚
    return MenuAnchor(
      controller: menuController,
      crossAxisUnconstrained: false,
      menuChildren: children,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.scaffoldBackgroundColor),
      ),
      onClose: () => _isOpen.value = false,
      onOpen: () => _isOpen.value = true,
      child: LayoutBuilder(builder: _buildField),
    );
  }

  /// 工具 [Shortcuts] 和 [Actions] 操作
  Widget _buildAction({required Widget child}) {
    // 快捷键
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const _ArrowUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const _ArrowDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const _ArrowEnterIntent(),
      },
      // 操作
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ArrowUpIntent: CallbackAction<_ArrowUpIntent>(
            onInvoke: handleUpKeyInvoke,
          ),
          _ArrowDownIntent: CallbackAction<_ArrowDownIntent>(
            onInvoke: handleDownKeyInvoke,
          ),
          _ArrowEnterIntent: CallbackAction<_ArrowEnterIntent>(
            onInvoke: handleEnterKeyInvoke,
          ),
        },
        child: child,
      ),
    );
  }

  /// 构建表单字段
  Widget _buildField(BuildContext context, BoxConstraints constraints) {
    // 最大宽度
    _maxWidth.value = constraints.maxWidth;
    // 后缀图标
    final suffixIcon = widget.selectedTrailingIcon ??
        widget.decoration?.suffixIcon ??
        Padding(
          padding: kRightPadding16,
          child: Obx(
            () => _isOpen.value ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
          ),
        );
    // 装饰器的构造函数
    final inputDecorationFun = widget.decoration != null ? widget.decoration!.copyWith : InputDecoration.new;
    // 创建装饰器
    final decoration = inputDecorationFun(
      isDense: true,
      contentPadding: kVer8Hor12,
      hoverColor: Colors.transparent,
      hintStyle: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.outline,
      ),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(),
      prefixIconConstraints: const BoxConstraints(),
    );
    // 返回字段
    return TextFormField(
      controller: textController,
      enabled: widget.enabled,
      readOnly: !widget.enableSearch,
      mouseCursor: widget.enableSearch ? null : SystemMouseCursors.click,
      decoration: decoration,
      onTap: widget.enabled ? _menuHandle : null,
      onChanged: (str) => _textField.value = widget.enableFilter ? str : '',
      inputFormatters: widget.inputFormatters,
    );
  }

  Object? handleUpKeyInvoke(_ArrowUpIntent intent) {
    return null;
  }

  Object? handleDownKeyInvoke(_ArrowDownIntent intent) {
    return null;
  }

  /// 回车打开或关闭
  Object? handleEnterKeyInvoke(_ArrowEnterIntent intent) {
    _menuHandle();
    return null;
  }

  /// 更新 [textController] 的值
  void _updateTextEditor() {
    final children = widget.children;
    _itemsNum.value = children.length;
    textController = widget.textController != null ? widget.textController! : TextEditingController();
    if (widget.initValue != null) {
      textController.text = widget.displayStringForItem(widget.initValue!);
    }
  }

  // 关闭和打卡菜单
  void _menuHandle() {
    // 启用搜索, 只能打开
    if (widget.enableSearch) {
      menuController.open();
      return;
    }
    // 点击一次打开, 然后再点击就会关闭
    if (menuController.isOpen) {
      menuController.close();
    } else {
      menuController.open();
    }
  }

  // 对 children 的 item 进行操作
  void _selectItem({required DropdownMenuItem<T> child, bool other = false}) {
    if (other) {
      child.onTap?.call();
      return;
    }
    textController.text = widget.displayStringForItem(child.value as T);
    widget.onSelected?.call(child.value as T);
    child.onTap?.call();
    menuController.close();
  }
}

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}

class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _ArrowEnterIntent extends Intent {
  const _ArrowEnterIntent();
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, TextInputFormatter;
import 'package:get/get.dart' show BoolExtension, DoubleExtension, FirstWhereOrNullExt, Get, GetNavigationExt, IntExtension, Obx, StringExtension, Trans;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

/// 下拉按钮菜单
class DropdownWidget<T> extends StatefulWidget {
  /// Creates a const [DropdownWidget].
  const DropdownWidget({
    super.key,
    this.enabled = true,
    this.initValue,
    this.initMultipleValue,
    this.width,
    this.itemHeight = _itemHeight,
    this.itemsMaxHeight = _itemsMaxHeight,
    this.itemPadding,
    this.selectedTrailingIcon,
    this.enableFilter = false,
    this.enableSearch = false,
    this.enableHighlight = false,
    this.enableMultiple = false,
    this.filterCallback,
    this.highlightBuild,
    this.multipleCallback,
    this.multipleSelectedPrefixBuild,
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

  /// 启用多选时的初始值
  ///
  /// 如果为 null, 默认为空
  final Set<T>? initMultipleValue;

  /// 确定 [DropdownWidget] 的宽度
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

  /// 启用 [item] 的多选
  final bool enableMultiple;

  /// [enableFilter] 为 true 时需要设置
  final TFilterCallback<T>? filterCallback;

  /// item 转字符串的函数
  final TDisplayStringForItem<T> displayStringForItem;

  /// [item] 的高亮自定义构建函数
  final TChangeValue<Widget>? highlightBuild;

  /// 多选时的前缀控件构建函数
  final TChangeCallback<Widget, Set<T>>? multipleSelectedPrefixBuild;

  /// 多选时的回调函数
  final TChangeCallback<void, Set<T>>? multipleCallback;

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
    _updateSelectItems();
  }

  @override
  void didUpdateWidget(covariant DropdownWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textController != oldWidget.textController) {
      _updateTextEditor(oldWidget: oldWidget);
    }
    if (widget.children != oldWidget.children) {
      _updateSelectItems(oldWidget: oldWidget);
    }
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
    return SizedBox(
      width: widget.width,
      child: _buildAction(
        child: _buildAnchor(
          children: children,
        ),
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
      _itemsNum.value = items.length;
      // list 构建 children
      return ListView.builder(
        shrinkWrap: true,
        itemExtent: widget.itemHeight,
        itemBuilder: (BuildContext context, int index) => _buildItemInk(child: items[index]),
        itemCount: _itemsNum.value,
      );
    });
  }

  /// 构建 [widget.children] 的 [Ink] 部分
  Widget _buildItemInk({required DropdownMenuItem<T> child, bool other = false}) {
    GestureTapCallback? onTap;
    Widget item = child;
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
        child: item,
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
      final width = _maxWidth.value;
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
      prefixIcon: _buildMultipleSelectedPrefix(),
      suffixIcon: _buildSelectedTrailingIcon(),
      suffixIconConstraints: const BoxConstraints(),
      prefixIconConstraints: const BoxConstraints(),
    );
    // 返回字段
    return TextFormField(
      maxLines: widget.enableMultiple ? null : 1,
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

  /// 构建拖尾图标
  Widget _buildSelectedTrailingIcon() {
    final suffixIcon = widget.selectedTrailingIcon ?? widget.decoration?.suffixIcon;
    if (suffixIcon != null) {
      return suffixIcon;
    }

    return Padding(
      padding: kRightPadding16,
      child: Obx(
        () => _isOpen.value ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  /// 构建多选时的前缀图标
  Widget? _buildMultipleSelectedPrefix() {
    if (!widget.enableMultiple) {
      return null;
    }
    // 自定义的构建函数
    final child = widget.multipleSelectedPrefixBuild?.call(Set.of(_selectItems.value));
    if (child != null) {
      return child;
    }
    // 默认构建函数
    return Obx(
      () => Padding(
        padding: kAllPadding16 / 4,
        child: Wrap(
          children: [
            for (var item in _selectItems.value)
              InputChip(
                label: Text(widget.displayStringForItem(item)),
                onDeleted: () {
                  var child = widget.children.firstWhereOrNull((t) => t.value == item);
                  if (child != null) {
                    _selectItem(child: child);
                  }
                },
                deleteIcon: const Icon(PhosphorIconsRegular.x),
                deleteButtonTooltipMessage: 'delete'.tr,
                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
      ),
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
  void _updateTextEditor({DropdownWidget<T>? oldWidget}) {
    final children = widget.children;
    // 数量
    _itemsNum.value = children.length;
    // 控制器
    textController = widget.textController != null ? widget.textController! : TextEditingController();
    if (oldWidget != null) {
      // 多选
      if (widget.enableMultiple) {
        _setTextField('');
      }
    }
  }

  /// 更新 [_selectItems]
  void _updateSelectItems({DropdownWidget<T>? oldWidget}) {
    // 控件更新时的操作
    if (oldWidget != null) {
      if (widget.children != oldWidget.children) {
        // 取公共的交集部分
        final items = widget.children.map((t) => t.value!).toSet();
        _selectItems.value = _selectItems.value.intersection(items);
      }
      return;
    }
    // 初始化
    // 多选时的初始值
    if (widget.enableMultiple) {
      if (widget.initMultipleValue?.isNotEmpty ?? false) {
        _selectItems.value.addAll(widget.initMultipleValue!);
        // 清空控制器
        _setTextField('');
      }
    } else if (widget.initValue != null) {
      // 非多选时的初始值
      T value = widget.initValue as T;
      _selectItems.value.clear();
      _selectItems.value.add(value);
      // 设置控制器显示的值
      _setTextField(widget.displayStringForItem(value));
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
    final item = child.value as T;
    if (other) {
      child.onTap?.call();
      return;
    }
    // 选择
    var isSelected = true;
    // 控制器的值
    _setTextField(widget.displayStringForItem(item));
    // 更新 _selectItems
    _selectItems.update((value) {
      // 单选
      if (!widget.enableMultiple) {
        // 未启用多选, 先清空 _selectItems, 在添加, 确保只有一个
        value.clear();
        value.add(item);
      } else if (value.contains(item)) {
        // 多选且 item 已经存在了, 需要移除
        value.remove(item);
        isSelected = false;
      } else {
        // 多选且 item 不经存在了, 需要添加
        value.add(item);
      }
      return value;
    });
    // isSelected == true, 调用 onSelected
    if (isSelected) {
      widget.onSelected?.call(item);
    }
    // widget.enableMultiple == true, 调用 multipleCallback
    if (widget.enableMultiple) {
      // 清空控制器的值
      _setTextField('');
      widget.multipleCallback?.call(Set.of(_selectItems.value));
    }
    child.onTap?.call();
    // 多选
    if (!widget.enableMultiple) {
      // 未启用多选, 则关闭菜单
      menuController.close();
    }
  }

  /// 设置 [textController] 和 [_textField] 的值
  void _setTextField(String str){
    textController.text = str;
    if(widget.enableFilter) {
      _textField.value = str;
    }
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

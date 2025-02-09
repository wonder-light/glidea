import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart' show CodeEditorTapRegion, CodeLineEditingController;
import 'package:re_editor/re_editor.dart' show MobileSelectionToolbarController, SelectionToolbarController, ToolbarMenuBuilder;

/// 桌面选择工具栏控制器
class _DesktopSelectionToolbarController extends SelectionToolbarController {
  final ToolbarMenuBuilder builder;
  OverlayEntry? _entry;

  _DesktopSelectionToolbarController({required this.builder});

  @override
  void hide(BuildContext context) {
    _entry?.remove();
    _entry = null;
  }

  @override
  void show({
    required BuildContext context,
    required CodeLineEditingController controller,
    required TextSelectionToolbarAnchors anchors,
    Rect? renderRect,
    required LayerLink layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    // 隐藏
    hide(context);
    // 获取 rootOverlay 实例
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    //controller.addListener(() => hide(context));
    // 创建子控件
    Widget buildOverlay(BuildContext context) {
      Widget child = builder(
        context: context,
        anchors: anchors,
        controller: controller,
        onDismiss: () {
          hide(context);
        },
        onRefresh: () {
          show(
            context: context,
            controller: controller,
            anchors: anchors,
            renderRect: renderRect,
            layerLink: layerLink,
            visibility: visibility,
          );
        },
      );
      child = CodeEditorTapRegion(child: child);
      child = Material(elevation: 2, child: child);
      return Positioned.fill(
        child: CustomSingleChildLayout(
          delegate: DesktopTextSelectionToolbarLayoutDelegate(anchor: anchors.primaryAnchor),
          child: child,
        ),
      );
    }

    // 创建 Overlay 实体
    final OverlayEntry entry = OverlayEntry(builder: buildOverlay);
    // 插入
    overlay.insert(entry);
    _entry = entry;
  }
}

/// Post 上下文菜单控制器
abstract class PostContextMenuController implements SelectionToolbarController {
  static SelectionToolbarController create({required ToolbarMenuBuilder builder}) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileSelectionToolbarController(builder: builder);
    } else {
      return _DesktopSelectionToolbarController(builder: builder);
    }
  }
}

/*class CodeShortcutsActivatorsBuilder extends DefaultCodeShortcutsActivatorsBuilder {
  @override
  List<ShortcutActivator>? build(CodeShortcutType type) {
    var activators = super.build(type);
    return activators;
  }
}*/

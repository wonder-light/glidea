import 'dart:io' show Platform;
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:window_manager/window_manager.dart' show TitleBarStyle, WindowListener, WindowOptions, windowManager;

class WindowsHelp {
  static Future<void> initialized() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) return;
    // 初始化
    await windowManager.ensureInitialized();
    // 选项
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(windowMinWidth + 120, windowMinHeight),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// 生命周期状态
abstract class LifecycleState<T extends StatefulWidget> extends State<T> with WindowListener {
  /// 侦听器，可用于侦听应用程序生命周期中的更改
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
    } else {
      _lifecycle = AppLifecycleListener(
        onShow: onAppShow,
        onHide: onAppHide,
        onExitRequested: onAppExitRequested,
      );
    }
  }

  @override
  void dispose() {
    print('------------------------dispose-------------------------------');
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.removeListener(this);
    } else {
      _lifecycle.dispose();
    }
    super.dispose();
  }

  /// 移动端 APP 显示
  void onAppShow() {}

  /// 移动端 APP 隐藏
  void onAppHide() {}

  /// 移动端 APP 退出
  ///
  /// 一个回调，用于询问应用程序是否允许在退出可以取消的情况下退出应用程序
  Future<AppExitResponse> onAppExitRequested() async => AppExitResponse.exit;
}

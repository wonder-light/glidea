import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:window_manager/window_manager.dart' show TitleBarStyle, WindowOptions, windowManager;

class WindowsHelp {
  static Future<void> initialized() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) return;

    //MediaQueryData.fromView(window);

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(windowMinWidth, windowMinHeight),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

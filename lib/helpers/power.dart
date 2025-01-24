import 'dart:io' show Platform;

import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions;

/// 权限
class Power {
  /// 请求权限
  static Future<void> request() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
}

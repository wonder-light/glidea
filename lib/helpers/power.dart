import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions;

/// 权限
class Power {
  /// 请求权限
  static Future<void> request() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
}

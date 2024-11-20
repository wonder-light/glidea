import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart' show JsonMapper;
import 'package:get/get.dart';
import 'package:glidea/models/application.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 站点控制器
class SiteController extends GetxController with StateMixin<Application> {
  /// 站点数据
  final Rx<Application> site = Application().obs;

  @override
  void onInit() {
    super.onInit();
    Future(() async {
      state.baseDir = Directory.current.path;
      state.appDir = p.join((await getApplicationDocumentsDirectory()).path, 'glidea');
      state.buildDir = p.join((await getApplicationSupportDirectory()).path, '../../../glidea');
    });
  }

  /// 更新站点数据
  void updateSite(Application siteData) {
    Map<String, dynamic>? data = JsonMapper.toMap(siteData);
    if (data == null) return;
    value = JsonMapper.copyWith(state, data)!;
    update();
  }
}

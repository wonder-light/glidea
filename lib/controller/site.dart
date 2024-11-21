import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart' show JsonMapper;
import 'package:get/get.dart' show GetxController, StateMixin, StatusDataExt;
import 'package:glidea/models/application.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 站点控制器
class SiteController extends GetxController with StateMixin<Application> {
  /// 发布的网址
  String get domain => state.db.themeConfig.domain;

  @override
  void onInit() async {
    super.onInit();
    setLoading();
    await initData();
  }

  Future<void> initData() async {
    var data = Application();
    data.baseDir = p.normalize(Directory.current.path);
    data.appDir = p.normalize(p.join((await getApplicationDocumentsDirectory()).path, 'glidea'));
    data.buildDir = p.normalize(p.join((await getApplicationSupportDirectory()).path, '../../../../glidea'));

    setSuccess(data);
  }

  /// 更新站点的全部数据
  void updateSite(Application siteData) {
    Map<String, dynamic>? data = JsonMapper.toMap(siteData);
    if (data == null) return;
    setSuccess(JsonMapper.copyWith(state, data)!);
  }

  /// 获取首页左侧面板上显示的数量
  String getHomeLeftPanelNum(String name) {
    // 加载中则返回默认字符串
    if (status.isLoading) return '';
    return switch (name) {
      'article' => '${state.db.posts.length}',
      'menu' => '${state.db.menus.length}',
      'tag' => '${state.db.tags.length}',
      _ => '',
    };
  }
}

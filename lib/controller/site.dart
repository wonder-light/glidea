import 'package:get/get.dart' show StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/menu.dart';
import 'package:glidea/controller/mixin/post.dart';
import 'package:glidea/controller/mixin/remote.dart';
import 'package:glidea/controller/mixin/tag.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';

/// 站点控制器
class SiteController extends StateController<Application> with EventBus, DataProcess, TagSite, MenuSite, PostSite, ThemeSite, RemoteSite {
  /// [SiteController] 的控制器标签
  static const String tag = 'site';

  @override
  void onInit() async {
    super.onInit();
    setLoading();
    value = await initData();
    initState();
    setSuccess(value);
  }

  @override
  void dispose() async {
    await disposeState();
    await Log.dispose();
    super.dispose();
  }

  /// 获取首页左侧面板上显示的数量
  String getHomeLeftPanelNum(String name) {
    // 加载中则返回默认字符串
    return switch (name) {
      Tran.article => '${state.posts.length}',
      Tran.menu => '${state.menus.length}',
      Tran.tag => '${state.tags.length}',
      _ => '',
    };
  }
}

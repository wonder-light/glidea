﻿import 'dart:async' show Completer;

import 'package:get/get.dart' show StateController;
import 'package:glidea/controller/mixin/data.dart';
import 'package:glidea/controller/mixin/menu.dart';
import 'package:glidea/controller/mixin/post.dart';
import 'package:glidea/controller/mixin/remote.dart';
import 'package:glidea/controller/mixin/tag.dart';
import 'package:glidea/controller/mixin/theme.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/application.dart';

/// 站点控制器
class SiteController extends StateController<Application> with DataProcess, TagSite, MenuSite, PostSite, ThemeSite, RemoteSite {
  /// [SiteController] 的控制器标签
  static const String tag = 'site';

  /// 初始化时的任务
  final Completer initTask = Completer();

  @override
  void onInit() async {
    super.onInit();
    setLoading();
    value = await initData();
    initState();
    setSuccess(value);
    initTask.complete(true);
  }

  @override
  void dispose() async {
    await disposeState();
    await Log.dispose();
    super.dispose();
  }
}

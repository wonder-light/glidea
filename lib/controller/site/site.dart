library;

import 'dart:async' show Completer;
import 'dart:io' show Directory;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart' show AsyncCallback, protected;
import 'package:flutter/material.dart' show Locale;
import 'package:get/get.dart' show Get, GetNavigationExt, StateController, Trans;
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/lang/translations.dart';
import 'package:glidea/library/worker/worker.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/menu.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/models/setting.dart';
import 'package:glidea/models/tag.dart';
import 'package:glidea/models/theme.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory, getApplicationSupportDirectory;

part 'data.dart';
part 'menu.dart';
part 'post.dart';
part 'remote.dart';
part 'tag.dart';
part 'theme.dart';

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
    value = await loadSiteData();
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

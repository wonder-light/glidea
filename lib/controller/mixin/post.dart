import 'package:get/get.dart' show StateController, StatusDataExt;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';

import 'package:path/path.dart' as p;

/// 混合 - 文章
mixin PostSite on StateController<Application> {
  /// 菜单
  List<Post> get posts => state.posts;

  /// 创建文章
  Post createPost() => Post();

  /// 获取文章封面图片的路径
  String getFeaturePath({required Post data, bool isWeb = false}){
    var feature = data.feature.isNotEmpty ? data.feature : Constants.defaultPostFeaturePath;
    // 去掉开头的 /
    if(feature.startsWith('/')){
      feature = feature.substring(1);
    }
    if(isWeb) return FS.join(state.themeConfig.domain, Constants.defaultPostPath, feature);
    return FS.join(state.appDir, feature);
  }
}

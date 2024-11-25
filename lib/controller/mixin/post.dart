import 'package:get/get.dart' show StateController;
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';

/// 混合 - 文章
mixin PostSite on StateController<Application> {
  /// 菜单
  List<Post> get posts => state.posts;
}

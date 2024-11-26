import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';

/// 混合 - 文章
mixin PostSite on StateController<Application> {
  /// 菜单
  List<Post> get posts => state.posts;

  /// 创建文章
  Post createPost() => Post();

  /// 获取文章封面图片的路径
  String getFeaturePath({required Post data, bool isWeb = false}) {
    var feature = data.feature.isNotEmpty ? data.feature : Constants.defaultPostFeaturePath;
    // 去掉开头的 /
    if (feature.startsWith('/')) {
      feature = feature.substring(1);
    }
    if (isWeb) return FS.join(state.themeConfig.domain, Constants.defaultPostPath, feature);
    return FS.join(state.appDir, feature);
  }

  /// 筛选文章
  ///
  /// [include]
  ///
  ///     false: 从 [Post.title] 中搜索数据
  ///     true: 从 [Post.title] 和 [Post.content] 中搜索数据
  List<Post> filterPost(String data, {bool include = false}) {
    if (data.isEmpty) return [...state.posts];

    bool compare(Post p) {
      final reg = RegExp(data, caseSensitive: false);
      return p.title.contains(reg) || (include && p.content.contains(reg));
    }

    return state.posts.where(compare).toList();
  }

  /// 删除新标签
  void removePost(Post data) {
    if (!state.posts.remove(data)) {
      Get.error('articleDeleteFailure');
      // 删除失败
      return;
    }
    // 标签
    var tags = data.tags;
    if (tags.isNotEmpty) {
      // 查看 posts 中是否还有相同的标签存在
      for (var tag in tags) {
        var value = state.posts.any((p) => p.tags.any((t) => t.slug == tag.slug));
        if (!value) {
          tag = state.tags.firstWhere((t) => t.slug == tag.slug);
          tag.used = false;
        }
      }
    }
    refresh();
    // 菜单中的列表不必管
    Get.success('articleDelete');
  }
}

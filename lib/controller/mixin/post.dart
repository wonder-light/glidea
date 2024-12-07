import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';

import 'data.dart';
import 'tag.dart';

/// 混合 - 文章
mixin PostSite on StateController<Application>, DataProcess, TagSite {
  /// 菜单
  List<Post> get posts => state.posts;

  @override
  void initState() {
    super.initState();
    updateTagUsedField();
  }

  /// 创建文章
  Post createPost() => Post();

  /// 获取文章封面图片的路径
  String getFeaturePath({required Post data}) {
    var feature = data.feature.isNotEmpty ? data.feature : defaultPostFeaturePath;
    return FS.joinR(state.appDir, feature);
  }

  /// 筛选文章
  ///
  /// [include]
  ///
  ///     false: 从 [Post.title] 中搜索数据
  ///     true: 从 [Post.title] 和 [Post.content] 中搜索数据
  List<Post> filterPost(String data, {bool include = false}) {
    if (data.isEmpty) return [...state.posts];
    // 比较
    bool compare(Post p) {
      final reg = RegExp(data, caseSensitive: false, multiLine: true);
      return p.title.contains(reg) || (include && p.content.contains(reg));
    }

    // 筛选
    return state.posts.where(compare).toList();
  }

  /// 获取文章的链接
  List<TLinkData> getPostLink() {
    final postPath = '/${state.themeConfig.postPath}/';
    // 文章的链接
    return [
      for (var post in state.posts)
        // 文章的链接
        (name: post.title, link: '$postPath${post.fileName}'),
    ];
  }

  /// 对文章链接进行筛选
  List<TLinkData> filterPostLink(String data) {
    // 筛选文章链接
    return getPostLink().where((p) => p.link.contains(data)).toList();
  }

  /// 删除 post
  void removePost(Post data) async {
    if (!state.posts.remove(data)) {
      // 删除失败
      Get.error('articleDeleteFailure');
      return;
    }
    // 标签
    updateTagUsedField();
    try {
      await saveSiteData();
    } on Mistake catch (e) {
      Log.w(e.message);
    }
    // 菜单中的列表不必管
    Get.success('articleDelete');
  }
}

import 'package:collection/collection.dart' show IterableExtension;
import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/error.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';

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

  /// 获取 [fileName] 对应的 post, 不然返回新的 [Post] 实例
  Post getPostOrDefault(String fileName) {
    // 没有时返回新的实例
    return state.posts.firstWhere((p) => p.fileName == fileName, orElse: () => Post());
  }

  /// 获取文章封面图片的路径
  String getFeaturePath(Post data, {bool usePrefix = true}) {
    var feature = data.feature.isNotEmpty ? data.feature : defaultPostFeaturePath;
    if (feature.startsWith('http')) {
      return feature;
    }
    feature = FS.join(state.appDir, feature);
    // 加上 file:// 前缀
    if (usePrefix) {
      feature = featurePrefix + feature;
    }
    return feature;
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

  /// 更新或者添加 post
  void updatePost({required Post newData, Post? oldData}) async {
    // 获取 [posts] 中的实例
    oldData = state.posts.firstWhereOrNull((p) => p == oldData);
    // 添加新的 post
    if (oldData == null) {
      state.posts.add(newData);
    } else {
      // 更新数据
      oldData
        ..title = newData.title
        ..content = newData.content
        ..fileName = newData.fileName
        ..date = newData.date
        ..feature = newData.feature
        ..hideInList = newData.hideInList
        ..isTop = newData.isTop
        ..published = newData.published
        // 摘要, 以 <!--\s*more\s*--> 进行分割, 获取被分割的第一个字符串, 否则返回 ''
        ..abstract = newData.content.split(summaryRegExp).firstOrNull ?? ''
        // 标签
        ..tags = newData.tags;
    }
    // 更新标签
    updateTagUsedField(addTag: true);
    try {
      // 保存
      await saveSiteData();
    } catch (e) {
      Log.w('update post failed: \n$e');
    }
    Get.success(newData.published ? 'saved' : 'draftSuccess');
  }

  /// 删除 post
  void removePost(Post data) async {
    if (!state.posts.remove(data)) {
      // 删除失败
      Get.error('articleDeleteFailure');
      return;
    }
    // 标签
    updateTagUsedField(addTag: false);
    try {
      // 保存
      await saveSiteData();
    } on Mistake catch (e) {
      Log.w(e.message);
    }
    // 菜单中的列表不必管
    Get.success('articleDelete');
  }

  /// 检测 [Post] 的命名是否添加或者更新
  ///
  /// true: 可以加入
  ///
  /// false: 文章的 URL 与其他文章重复
  bool checkPost(Post data, [Post? oldData]) {
    // 必须要有标题和内容
    if (data.title.trim().isEmpty || data.content.trim().isEmpty) {
      return false;
    }
    // fileName
    if (data.fileName.trim().isEmpty || data.fileName.contains('/')) {
      return false;
    }
    // 判断 fileName 是否有重复的
    final length = state.posts.where((p) => p.fileName == data.fileName && p != oldData).length;
    return length <= 0;
  }

  /// 比较 post 是否相等
  bool equalPost(Post prev, Post next) {
    // 标签
    // 其它
    return prev.title == next.title &&
        prev.content == next.content &&
        prev.fileName == next.fileName &&
        prev.date == next.date &&
        prev.feature == next.feature &&
        prev.hideInList == next.hideInList &&
        prev.isTop == next.isTop &&
        equalPostTags(prev.tags, next.tags);
  }

  /// 比较 post 中的 tags 是否相等
  bool equalPostTags(List<Tag> prev, List<Tag> next) {
    final tag1 = prev.map((t) => t.slug).toSet();
    final tag2 = next.map((t) => t.slug).toSet();
    final tag3 = tag1.union(tag2);
    return tag1.length == tag3.length && tag3.length == tag2.length;
  }
}

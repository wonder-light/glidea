part of 'site.dart';

/// 混合 - 标签
mixin TagSite on DataProcess {
  /// 标签
  List<Tag> get tags => state.tags;

  /// 记录标签 <tag.slug, tag>
  Map<String, Tag> _tagsMap = {};

  @override
  void initState() {
    super.initState();
    // 初始化映射
    _tagsMap = {
      for (var tag in state.tags) tag.slug: tag,
    };
  }

  /// 创建标签, 需要保证 slug 唯一
  Tag createTag({String? slug}) {
    return slug != null ? (Tag()..slug = slug) : Tag();
  }

  /// 从 [post.tags] 中获取对应的 [tags] 获取
  List<Tag> getTagsWithPost(Post post) {
    List<Tag> items = [];
    for (var slug in post.tags) {
      final tag = _tagsMap[slug];
      if (tag != null) {
        items.add(tag);
      }
    }
    return items;
  }

  /// 更新或添加标签, 当 [oldData] 为 null 时添加标签, 否则就会更新标签
  Future<bool> updateTag({required Tag newData, Tag? oldData}) async {
    try {
      // 更新
      final index = oldData == null ? -1 : state.tags.indexOf(oldData);
      if (index >= 0) {
        state.tags[index] = newData;
      } else {
        state.tags.add(newData);
      }
      // 更新标签
      _tagsMap.remove(oldData?.slug);
      _tagsMap[newData.slug] = newData;
      await saveSiteData();
      return true;
    } catch (e, s) {
      Log.e('update or add tag failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 删除标签
  Future<bool> removeTag(Tag tag) async {
    try {
      // 删除标签
      state.tags.remove(tag);
      // 移除映射中的标签
      _tagsMap.remove(tag.slug);
      await saveSiteData();
      return true;
    } catch (e, s) {
      Log.e('remove tag failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// 检测 [Tag] 的命名是否添加或者更新
  ///
  /// true: 可以加入
  ///
  /// false: 文章的 URL 与其他文章重复
  bool checkTag(Tag data, [Tag? oldData]) {
    // 不符合
    if (data.name.isEmpty || data.slug.isEmpty) {
      return false;
    }
    // 查找是否有重复的, 需要把 oldData 排除
    return !state.tags.any((t) => (t.slug == data.slug || t.name == data.name) && t != oldData);
  }

  /// 更新标签中 [Tag.used] 字段的值
  ///
  /// [addTag] == true, 将 [post] 中的标签添加到 [state.tags] 中, 否则删除它
  void updateTagUsedField() {
    // 清空
    _tagsMap = {
      for (var tag in state.tags)
        // 将 use 重置为 false
        tag.slug: tag..used = false,
    };
    // 循环 post
    for (var post in state.posts) {
      final List<String> tags = [];
      // 循环 post 中的 tags
      for (var tagSlug in post.tags) {
        // 判断是否有对应的 tag
        if (_tagsMap[tagSlug] case Tag tag) {
          tag.used = true;
          tags.add(tagSlug);
        }
      }
      // 设置 post.tags
      post.tags = tags;
    }
  }
}

import 'package:get/get.dart' show Get, StateController;
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/tag.dart';

import 'data.dart';

/// 混合 - 标签
mixin TagSite on StateController<Application>, DataProcess {
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
  Tag createTag() {
    return Tag()..slug = Uid.shortId;
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
  void updateTag({required Tag newData, Tag? oldData}) async {
    // 更新
    state.tags.remove(oldData);
    state.tags.add(newData);
    _tagsMap.remove(oldData?.slug);
    // 添加新的标签
    _tagsMap[newData.slug] = newData;
    try {
      await saveSiteData();
      Get.success(Tran.tagSuccess);
    } catch (e) {
      Log.e('update tag failed: $e');
      Get.error(Tran.saveError);
    }
  }

  /// 删除标签
  void removeTag(Tag tag) async {
    // 判断是否还在使用
    if (tag.used) return;
    // 删除标签
    state.tags.remove(tag);
    // 移除映射中的标签
    _tagsMap.remove(tag.slug);
    try {
      await saveSiteData();
      Get.success(Tran.tagDelete);
    } catch (e) {
      Log.w('remove tag failed: $e');
      Get.error(Tran.tagDeleteFailure);
    }
  }

  /// 检测 [Tag] 的命名是否添加或者更新
  ///
  /// true: 可以加入
  ///
  /// false: 文章的 URL 与其他文章重复
  bool checkTag(Tag data, [Tag? oldData]) {
    // 不符合
    if (data.name.trim().isEmpty || data.slug.trim().isEmpty) {
      return false;
    }
    // 查找是否有重复的, 需要把 oldData 排除
    return state.tags.any((t) => (t.slug == data.slug || t.name == data.name) && t != oldData);
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
        if (_tagsMap[tagSlug] is Tag) {
          tags.add(tagSlug);
        }
      }
      // 设置 post.tags
      post.tags = tags;
    }
  }
}

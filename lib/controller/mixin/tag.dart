import 'package:get/get.dart' show FirstWhereOrNullExt, Get, StateController;
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/uid.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/tag.dart';

import 'data.dart';

/// 混合 - 标签
mixin TagSite on StateController<Application>, DataProcess {
  /// 标签
  List<Tag> get tags => state.tags;

  /// 记录标签
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

  /// 更新标签
  void updateTag({required Tag newData, Tag? oldData}) async {
    // 移除旧标签, 当 [oldData] = null 时, remove 返回 null
    oldData = _tagsMap.remove(oldData?.slug);
    if (oldData == null) {
      // 添加标签
      state.tags.add(oldData = newData);
    } else {
      // 更新
      oldData.name = newData.name;
      oldData.slug = newData.slug;
    }
    // 添加更新后的标签
    _tagsMap[oldData.slug] = oldData;
    try {
      await saveSiteData();
    } catch (e) {
      Log.w('update tag failed: $e');
    }
    Get.success('tagSuccess');
  }

  /// 删除新标签
  void removeTag(Tag tag) async {
    // 判断是否还在使用
    if (tag.used) return;
    // 判断是否移除失败
    if (!state.tags.remove(tag)) {
      Get.error('tagDeleteFailure');
      return;
    }
    // 移除映射中的标签
    _tagsMap.remove(tag.slug);
    try {
      await saveSiteData();
    } catch (e) {
      Log.w('remove tag failed: $e');
    }
    Get.success('tagDelete');
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
    // 查找是否有重复的, 需要吧 oldData 排除
    final length = state.tags.where((t) => (t.slug == data.slug || t.name == data.name) && t != oldData).length;
    return length <= 0;
  }

  /// 更新标签中 [Tag.used] 字段的值
  ///
  /// [addTag] == true, 将 [post] 中的标签添加到 [site.tags] 中, 否则删除它
  void updateTagUsedField({bool addTag = false}) {
    // 清空
    _tagsMap = {};
    // 将 use 重置为 false
    for (var tag in state.tags) {
      _tagsMap[tag.slug] = tag..used = false;
    }
    // 循环 post
    for (var post in state.posts) {
      final List<Tag> tags = [];
      // 循环 post 中的 tags
      for (var item in post.tags) {
        // 判断是否有对应的 tag
        if (_tagsMap[item.slug] case Tag tag) {
          tag.used = true;
          tags.add(tag);
        } else if (addTag) {
          // 添加 post 中的 tag 没有记录
          tags.add(item);
          _tagsMap[item.slug] = item..used = true;
        }
      }
      // 设置 post.tags
      post.tags = tags;
    }
  }
}

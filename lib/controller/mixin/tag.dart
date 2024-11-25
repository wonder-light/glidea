import 'package:get/get.dart' show FirstWhereOrNullExt, StateController;
import 'package:glidea/helpers/uid.dart';
import 'package:glidea/models/application.dart';
import 'package:glidea/models/tag.dart';

/// 混合 - 标签
mixin TagSite on StateController<Application> {
  /// 标签
  List<Tag> get tags => state.tags;

  /// 创建标签, 需要保证 slug 唯一
  Tag createTag() {
    return Tag()..slug = Uid.shortId;
  }

  /// 更新标签
  void updateTag({required Tag newTag, Tag? oldTag}) {
    oldTag = state.tags.firstWhereOrNull((t) => t == oldTag);
    if (oldTag == null) {
      // 添加标签
      state.tags.add(newTag);
    } else {
      // 更新
      oldTag.name = newTag.name;
      oldTag.slug = newTag.slug;
    }
    refresh();
  }

  /// 删除新标签
  void removeTag(Tag tag) {
    if (tag.used) return;
    if (state.tags.remove(tag)) {
      refresh();
      // TODO: 保存标签
    }
  }
}
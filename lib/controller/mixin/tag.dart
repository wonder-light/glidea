import 'package:get/get.dart' show FirstWhereOrNullExt, Get, StateController;
import 'package:glidea/helpers/get.dart';
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
  void updateTag({required Tag newData, Tag? oldData}) {
    oldData = state.tags.firstWhereOrNull((t) => t == oldData);
    if (oldData == null) {
      // 添加标签
      state.tags.add(newData);
    } else {
      // 更新
      oldData.name = newData.name;
      oldData.slug = newData.slug;
    }
    refresh();
    Get.success('tagSuccess');
  }

  /// 删除新标签
  void removeTag(Tag tag) {
    if (tag.used) return;
    if (!state.tags.remove(tag)) {
      Get.error('tagDeleteFailure');
    }

    refresh();
    Get.success('tagDelete');
  }
}
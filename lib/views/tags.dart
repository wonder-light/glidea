import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/dialog.dart';
import 'package:glidea/components/drawer.dart';
import 'package:glidea/components/tagEditor.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/models/tag.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class TagsWidget extends StatefulWidget {
  const TagsWidget({super.key});

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  /// 当前路由索引
  var selectedTag = ''.obs;

  /// 站点控制器
  final siteController = Get.find<SiteController>(tag: 'site');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
            child: IconButton(
              onPressed: addNewTag,
              icon: const Icon(PhosphorIconsRegular.plus),
              tooltip: 'newTag'.tr,
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (var tag in siteController.tags) _buildTagButton(tag),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签按钮
  Widget _buildTagButton(Tag tag) {
    // 使用中不可删除
    final select = tag.used ? [false] : [false, false];
    // 按钮
    final buttons = [
      Container(
        padding: const EdgeInsets.only(left: 12, right: 16, top: 6, bottom: 6),
        child: Row(
          children: [
            const Icon(PhosphorIconsRegular.tag),
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: Text(tag.name),
            )
          ],
        ),
      ),
      if (!tag.used)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const Icon(PhosphorIconsRegular.trash),
        ),
    ];
    // 按钮
    return ToggleButtons(
      isSelected: select,
      children: buttons,
      onPressed: (index) {
        (index <= 0 ? editorTag : deleteTag)(tag);
      },
    );
  }

  /// 添加新标签
  void addNewTag() {
    editorTag(siteController.createTag());
  }

  /// 编辑标签
  void editorTag(Tag tag) {
    /// 抽屉控制器
    final drawerController = DraController();

    Get.showDrawer(
      controller: drawerController,
      builder: (context) => TagEditorWidget(
        tag: tag,
        controller: drawerController,
      ),
    );
  }

  /// 删除标签
  void deleteTag(Tag tag) {
    // 弹窗
    Get.dialog(DialogWidget(
      onCancel: () {
        Get.backLegacy();
      },
      onConfirm: () {
        siteController.removeTag(tag);
        Get.backLegacy();
      },
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/tag/tag_editor.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/tag.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class TagsView extends StatefulWidget {
  const TagsView({super.key});

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  /// 当前路由索引
  var selectedTag = ''.obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        TipWidget.down(
          message: Tran.newTag.tr,
          child: IconButton(
            onPressed: addNewTag,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ),
      ],
      child: Obx(
        () => Wrap(
          spacing: kAllPadding16.right,
          runSpacing: kHorPadding12.right,
          children: [
            for (var tag in site.tags) _buildTagButton(tag),
          ],
        ),
      ),
    );
  }

  /// 构建标签按钮
  Widget _buildTagButton(Tag tag) {
    // 边距
    final padding = kHorPadding8 + kVerPadding4;
    // 按钮
    return ToggleButtons(
      isSelected: [false, if (!tag.used) false],
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              const Icon(PhosphorIconsRegular.tag),
              Padding(padding: kRightPadding4),
              Text(tag.name),
            ],
          ),
        ),
        if (!tag.used)
          Padding(
            padding: padding,
            child: const Icon(PhosphorIconsRegular.trash),
          ),
      ],
      onPressed: (index) => index <= 0 ? editorTag(tag) : deleteTag(tag),
    );
  }

  /// 添加新标签
  void addNewTag() {
    editorTag(site.createTag());
  }

  /// 编辑标签
  void editorTag(Tag tag) {
    final isPhone = Get.isPhone;
    Get.showDrawer(
      direction: isPhone ? DrawerDirection.center : DrawerDirection.rightToLeft,
      stepHeight: isPhone ? 20 : null,
      builder: (context) => TagEditor(
        entity: tag,
        onSave: (data) async {
          final value = await site.updateTag(newData: data, oldData: tag);
          value ? Get.success(Tran.tagSuccess) : Get.error(Tran.saveError);
        },
      ),
    );
  }

  /// 删除标签
  void deleteTag(Tag tag) {
    // 弹窗
    Get.dialog(DialogWidget(
      onCancel: () => Get.backLegacy(),
      onConfirm: () async {
        final value = await site.removeTag(tag);
        value ? Get.success(Tran.tagDelete) : Get.error(Tran.tagDeleteFailure);
        Get.backLegacy();
      },
    ));
  }
}

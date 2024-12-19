import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/tag/tag_editor.dart';
import 'package:glidea/controller/site.dart';
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
    // 使用中不可删除
    final select = tag.used ? [false] : [false, false];
    // 边距
    final padding = kHorPadding8 + kVerPadding4;
    // 按钮
    final buttons = [
      Container(
        padding: padding * 1.5,
        child: Row(
          children: [
            const Icon(PhosphorIconsRegular.tag),
            Container(padding: kRightPadding4),
            Text(tag.name),
          ],
        ),
      ),
      if (!tag.used)
        Container(
          padding: padding,
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
        onSave: (data) {
          site.updateTag(newData: data, oldData: tag);
        },
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
        site.removeTag(tag);
        Get.backLegacy();
      },
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart' show Get;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/tag.dart';

/// 编辑标签的控件
class TagEditor extends DrawerEditor<Tag> {
  const TagEditor({
    super.key,
    required super.entity,
    super.controller,
    super.onClose,
    super.onSave,
    super.header = Tran.tag,
  });

  @override
  TagEditorState createState() => TagEditorState();
}

class TagEditorState extends DrawerEditorState<TagEditor> {
  /// 标签名控制器
  late final TextEditingController nameController = TextEditingController(text: widget.entity.name);

  /// 标签 URL 控制器
  late final TextEditingController urlController = TextEditingController(text: widget.entity.slug);

  @override
  void initState() {
    super.initState();
    // 初始化文本
    nameController.addListener(updateTagState);
    urlController.addListener(updateTagState);
  }

  @override
  Widget? buildContent(BuildContext context, int index) {
    return switch (index) {
      0 => wrapperField(name: Tran.tagName, child: _buildName()),
      1 => wrapperField(name: Tran.tagUrl, child: _buildUrl()),
      _ => null,
    };
  }

  /// 修改名称
  Widget _buildName() {
    return TextFormField(
      controller: nameController,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
      ),
    );
  }

  /// 修改 Url
  Widget _buildUrl() {
    return TextFormField(
      controller: urlController,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]+')),
      ],
    );
  }

  /// 更新标签状态
  void updateTagState() {
    var name = nameController.text;
    var url = urlController.text;
    // 确保都有效
    var pop1 = name.isNotEmpty && url.isNotEmpty;
    // 任意一个改变即可
    var pop2 = pop1 && (name != widget.entity.name || url != widget.entity.name);
    canSave.value = pop2;
  }

  @override
  void onSave() {
    if (canSave.value) {
      var newTag = Tag()
        ..name = nameController.text
        ..slug = urlController.text;
      if (!site.checkTag(newTag, widget.entity)) {
        Get.error(Tran.tagUrlRepeatTip);
        return;
      }
      widget.onSave?.call(newTag);
    }
    super.onSave();
  }
}

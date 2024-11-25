import 'package:flutter/material.dart';
import 'package:get/get.dart' show Trans;
import 'package:glidea/components/drawerEditor.dart';
import 'package:glidea/models/tag.dart';

class TagEditor extends DrawerEditor<Tag> {
  const TagEditor({
    super.key,
    required super.entity,
    required super.controller,
    super.onClose,
    super.onSave,
    super.header = 'tag',
  });

  @override
  TagEditorState createState() => TagEditorState();
}

class TagEditorState extends DrawerEditorState<Tag> {
  /// 标签名控制器
  final TextEditingController nameController = TextEditingController();

  /// 标签 URL 控制器
  final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化文本
    nameController.text = widget.entity.name;
    urlController.text = widget.entity.slug;
    nameController.addListener(updateTagState);
    urlController.addListener(updateTagState);
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    // 名称控件
    final nameWidget = wrapperField(
      name: 'tagName',
      child: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          hoverColor: Colors.transparent, // 悬停时的背景色
        ),
      ),
    );
    // 连接控件
    final linkWidget = wrapperField(
      name: 'tagUrl',
      child: TextField(
        controller: urlController,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          hoverColor: Colors.transparent, // 悬停时的背景色
        ),
      ),
    );

    return [
      nameWidget,
      linkWidget,
    ];
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
      siteController.updateTag(newTag: newTag, oldTag: widget.entity);
    }
    super.onSave();
  }
}

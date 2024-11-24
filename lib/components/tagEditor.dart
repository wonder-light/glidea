import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Obx, Trans, Inst, BoolExtension;
import 'package:glidea/components/drawer.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/models/tag.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class TagEditorWidget extends StatefulWidget {
  const TagEditorWidget({
    super.key,
    required this.tag,
    required this.controller,
  });

  /// 标签
  final Tag tag;

  /// 抽屉控制器
  final DraController controller;

  @override
  State<TagEditorWidget> createState() => _TagEditorWidgetState();
}

class _TagEditorWidgetState extends State<TagEditorWidget> {
  var canSave = false.obs;

  /// 站点控制器
  final siteController = Get.find<SiteController>(tag: 'site');

  /// 标签名控制器
  final TextEditingController tagNameController = TextEditingController();

  /// 标签 URL 控制器
  final TextEditingController tagUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化文本
    tagNameController.text = widget.tag.name;
    tagUrlController.text = widget.tag.slug;
    tagNameController.addListener(updateTagState);
    tagUrlController.addListener(updateTagState);
  }

  @override
  Widget build(BuildContext context) {
    //保存和取消
    Widget actions = _buildActions();
    // 头
    Widget header = Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('tag'.tr, textScaler: const TextScaler.linear(1.2)),
          IconButton(
            onPressed: close,
            icon: const Icon(PhosphorIconsRegular.x),
          ),
        ],
      ),
    );
    // 标签段
    List<Widget> tags = _buildFields();
    // 加入 header
    tags.insert(0, header);
    // 字段
    Widget widgets = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: tags,
      ),
    );
    // 上下两部分
    widgets = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [widgets, actions],
    );
    // 返回控件
    return widgets;
  }

  /// 构建字段
  List<Widget> _buildFields() {
    final items = [
      (name: 'tagName', controller: tagNameController),
      (name: 'tagUrl', controller: tagUrlController),
    ];

    return items
        .map(
          (item) => Container(
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(item.name.tr, textScaler: const TextScaler.linear(1.2)),
                ),
                TextField(
                  controller: item.controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    hoverColor: Colors.transparent, // 悬停时的背景色
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  /// 构建底部操作按钮
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: close,
            child: Text('cancel'.tr),
          ),
          Container(width: 8),
          Obx(
            () => FilledButton(
              onPressed: canSave.value ? save : null,
              child: Text('save'.tr),
            ),
          ),
        ],
      ),
    );
  }

  /// 更新标签状态
  void updateTagState() {
    var name = tagNameController.text;
    var url = tagUrlController.text;
    // 确保都有效
    var pop1 = name.isNotEmpty && url.isNotEmpty;
    // 任意一个改变即可
    var pop2 = pop1 && (name != widget.tag.name || url != widget.tag.name);
    canSave.value = pop2;
  }

  /// 关闭
  void close() {
    widget.controller.close();
  }

  /// 保存
  void save() {
    var newTag = Tag()
      ..name = tagNameController.text
      ..slug = tagUrlController.text;
    siteController.updateTag(newTag: newTag, oldTag: widget.tag);
    close();
  }
}

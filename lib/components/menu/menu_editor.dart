import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, RxT, Trans;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/menu.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

/// 菜单编辑器
class MenuEditor extends DrawerEditor<Menu> {
  const MenuEditor({
    super.key,
    required super.entity,
    super.controller,
    super.onClose,
    super.onSave,
    super.header = Tran.menu,
  });

  @override
  MenuEditorState createState() => MenuEditorState();
}

class MenuEditorState extends DrawerEditorState<MenuEditor> {
  /// 内链后或者外链类型
  late final openType = widget.entity.openType.obs;

  /// 标签名控制器
  late final TextEditingController nameController = TextEditingController(text: widget.entity.name);

  /// 标签 URL 控制器
  late final TextEditingController urlController = TextEditingController(text: widget.entity.link);

  /// 可以引用的链接
  final List<TLinkData> linkData = [];

  @override
  void initState() {
    super.initState();
    // 初始化文本
    nameController.addListener(updateTagState);
    urlController.addListener(updateTagState);
    linkData.addAll(site.getReferenceLink());
  }

  @override
  Widget? buildContent(BuildContext context, int index) {
    return switch (index) {
      0 => wrapperField(name: Tran.name, child: _buildName()),
      1 => wrapperField(child: _buildSelect()),
      2 => wrapperField(name: Tran.link, child: _buildLink()),
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

  /// 修改链接类型
  Widget _buildSelect() {
    return Obx(
      () => ToggleButtons(
        borderRadius: BorderRadius.circular(8),
        constraints: const BoxConstraints.tightFor(height: kButtonHeight * 0.8),
        // 取消最小高度
        isSelected: [
          openType.value == MenuTypes.internal,
          openType.value == MenuTypes.external,
        ],
        children: [
          for (var item in MenuTypes.values)
            Container(
              padding: kHorPadding16,
              child: Text(item.name.tr),
            ),
        ],
        onPressed: (index) {
          openType.value = index <= 0 ? MenuTypes.internal : MenuTypes.external;
        },
      ),
    );
  }

  /// 修改选择的链接
  Widget _buildLink() {
    // 高度
    const itemHeight = 54.0;
    return DropdownWidget(
      itemHeight: itemHeight,
      itemsMaxHeight: itemHeight * 3,
      enableSearch: true,
      enableFilter: true,
      textController: urlController,
      filterCallback: (item, text) {
        return item.name.contains(text) || item.link.contains(text);
      },
      displayStringForItem: (item) => item.link,
      children: [
        for (var item in linkData)
          DropdownMenuItem(
            value: item,
            child: ListItem(
              leading: const Icon(PhosphorIconsRegular.link),
              title: Text(item.name),
              subtitle: Text(item.link),
              subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              constraints: const BoxConstraints.expand(height: itemHeight),
              dense: true,
            ),
          ),
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
      var newMenu = Menu()
        ..name = nameController.text
        ..link = urlController.text;
      widget.onSave?.call(newMenu);
    }
    super.onSave();
  }
}

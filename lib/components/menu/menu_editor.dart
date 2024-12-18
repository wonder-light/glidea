import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Obx, RxT, Trans;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
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
    super.header = 'menu',
  });

  @override
  MenuEditorState createState() => MenuEditorState();
}

class MenuEditorState extends DrawerEditorState<MenuEditor> {
  /// 内链后或者外链类型
  var openType = MenuTypes.internal.obs;

  /// 标签名控制器
  final TextEditingController nameController = TextEditingController();

  /// 标签 URL 控制器
  final TextEditingController urlController = TextEditingController();

  /// 可以引用的链接
  final List<TLinkData> linkData = [];

  @override
  void initState() {
    super.initState();
    // 初始化文本
    nameController.text = widget.entity.name;
    urlController.text = widget.entity.link;
    nameController.addListener(updateTagState);
    urlController.addListener(updateTagState);
    openType.value = widget.entity.openType;
    linkData.addAll(site.getReferenceLink());
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;
    // 高度
    const itemHeight = 54.0;
    // 名称控件
    final nameWidget = wrapperField(
      name: 'name',
      child: TextFormField(
        controller: nameController,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: kVer8Hor12,
          hoverColor: Colors.transparent, // 悬停时的背景色
        ),
      ),
    );
    // 选择按钮
    final selectWidget = wrapperField(
      child: Obx(
        () => ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints.tightFor(height: kButtonHeight * 0.8),  // 取消最小高度
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
      ),
    );
    // 链接控件
    final linkWidget = wrapperField(
      name: 'link',
      child: DropdownWidget(
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
                subtitleTextStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
                constraints: const BoxConstraints.expand(height: itemHeight),
                dense: true,
              ),
            ),
        ],
      ),
    );
    return [
      nameWidget,
      selectWidget,
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
      var newMenu = Menu()
        ..name = nameController.text
        ..link = urlController.text;
      widget.onSave?.call(newMenu);
    }
    super.onSave();
  }
}

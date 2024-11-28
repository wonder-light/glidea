import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' show Obx, RxT, Trans;
import 'package:glidea/components/Common/Autocomplete.dart';
import 'package:glidea/components/Common/ListItem.dart';
import 'package:glidea/components/Common/drawerEditor.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/menu.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class MenuEditor extends DrawerEditor<Menu> {
  const MenuEditor({
    super.key,
    required super.entity,
    required super.controller,
    super.onClose,
    super.onSave,
    super.header = 'menu',
  });

  @override
  MenuEditorState createState() => MenuEditorState();
}

class MenuEditorState extends DrawerEditorState<Menu> {
  /// 内链后或者外链类型
  var openType = MenuTypes.internal.obs;

  /// 标签名控制器
  final TextEditingController nameController = TextEditingController();

  /// 标签 URL 控制器
  final TextEditingController urlController = TextEditingController();

  /// 可以引用的链接
  final List<TLinkData> linkData = [];

  /// 链接字段的全局键
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 初始化文本
    nameController.text = widget.entity.name;
    urlController.text = widget.entity.link;
    nameController.addListener(updateTagState);
    urlController.addListener(updateTagState);
    openType.value = widget.entity.openType;
    linkData.addAll(siteController.getReferenceLink());
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    // 名称控件
    final nameWidget = wrapperField(
      name: 'name',
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
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
          //constraints: const BoxConstraints(),  // 取消最小高度
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
      child: AutocompleteField(
        controller: urlController,
        optionsBuilder: _getOptions,
        optionsViewBuilder: _buildOptionsView,
        displayStringForOption: (option) => option.link,
        onSelected: (value) => urlController.text = value.link,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'(/(?!/)[a-zA-Z0-9-_.]*)+')),
        ],
      ),
    );
    return [
      nameWidget,
      selectWidget,
      linkWidget,
    ];
  }

  /// 构建列表选项组件
  Widget _buildOptionsView<T extends TLinkData>(BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
    // 获取链接字段的宽度
    final maxWidth = _key.currentContext?.findRenderObject()?.semanticBounds.width ?? double.infinity;
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 10,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 260,
            maxWidth: maxWidth,
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return ListItem(
                leading: const Icon(PhosphorIconsRegular.link),
                onTap: () {
                  onSelected(option);
                },
                title: Text(option.name),
                subtitle: Text(option.link),
                dense: true,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 1, thickness: 1);
            },
          ),
        ),
      ),
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

  /// 获取选项
  Iterable<TLinkData> _getOptions(TextEditingValue textEditingValue) {
    var text = textEditingValue.text;
    if (text.isEmpty) return linkData;
    return linkData.where((t) => t.name.contains(text) || t.link.contains(text));
  }
}

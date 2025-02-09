import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' show BottomActionBarConfig, CategoryViewConfig, Config, EmojiPicker, EmojiViewConfig;
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/post/post_editor.dart';
import 'package:glidea/components/post/preview.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:re_editor/re_editor.dart' show CodeLineEditingController, CodeLineSelection;

/// [PostView] 左边的工具条
class PostToolbar extends StatefulWidget {
  const PostToolbar({super.key, required this.entity, required this.picture, required this.controller});

  /// 当前使用的 Post
  final Post entity;

  /// 当前使用的 Post 的图片配置
  final PictureConfig picture;

  /// 编辑器字段的控制器
  final CodeLineEditingController controller;

  @override
  State<PostToolbar> createState() => _PostToolbarState();
}

class _PostToolbarState extends State<PostToolbar> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 主题数据
  late final theme = Theme.of(Get.context!);

  /// 主题颜色
  late final colorScheme = theme.colorScheme;

  /// 表情图标的菜单控制器
  final emojiController = MenuController();

  /// 表情图标的宽度
  final emojiWidth = 300.0;

  /// 右侧的工具栏按钮
  late final List<TActionIcon> toolbars = [
    (name: Tran.insertImage, call: insertImage, icon: PhosphorIconsRegular.image),
    (name: Tran.insertMore, call: insertSeparator, icon: PhosphorIconsRegular.dotsThreeOutline),
    (name: Tran.postSettings, call: openPostSetting, icon: PhosphorIconsRegular.gear),
    (name: Tran.preview, call: previewPost, icon: PhosphorIconsRegular.eye),
  ];

  /// 表情图标的配置
  late final Config emojiConfig = _getEmojiConfig();

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildEmoji(),
        for (var item in toolbars)
          TipWidget.left(
            message: item.name.tr,
            child: IconButton(
              onPressed: item.call,
              icon: Icon(item.icon, color: colorScheme.outlineVariant),
            ),
          ),
      ],
    );
    // 位置
    return Positioned(right: 16, top: 0, bottom: 0, child: widget);
  }

  /// 显示表情图标
  Widget buildEmoji() {
    final offset = Offset(-(emojiWidth + 20), -(emojiConfig.height / 2));
    return MenuAnchor(
      //layerLink: LayerLink(),
      alignmentOffset: offset,
      crossAxisUnconstrained: false,
      controller: emojiController,
      style: MenuStyle(backgroundColor: WidgetStatePropertyAll(theme.scaffoldBackgroundColor)),
      menuChildren: [
        SizedBox(
          width: emojiWidth,
          child: EmojiPicker(
            config: emojiConfig,
            onEmojiSelected: (category, emoji) => insertSeparator(separator: emoji.emoji),
          ),
        ),
      ],
      child: TipWidget.left(
        message: Tran.insertEmoji.tr,
        child: IconButton(
          onPressed: () => emojiController.isOpen ? emojiController.close() : emojiController.open(),
          icon: Icon(PhosphorIconsRegular.smiley, color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  /// 显示 post 统计信息
  void showPostStats() {}

  /// 插入图片
  void insertImage() async {
    // 实例化选择图片
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: imageExt,
    );
    if (result?.paths.firstOrNull?.isEmpty ?? true) return;
    // 选择的图片路径
    var path = FS.normalize(result!.paths.first!);
    var target = FS.join(site.state.appDir, 'post-images', '${DateTime.now().millisecondsSinceEpoch}${FS.extension(path)}');
    // 保存并压缩
    await ImageExt.compress(path, target);
    // 在 markdown 插入图片
    insertSeparator(separator: '![]($featurePrefix$target)');
  }

  /// 插入分隔符
  void insertSeparator({String separator = summarySeparator}) {
    final position = CodeLineSelection.fromPosition(position: widget.controller.selection.end);
    widget.controller.replaceSelection(separator, position);
  }

  /// 预览 post
  void previewPost() {
    final isPhone = Get.isPhone;
    Get.showDrawer(
      stepWidth: isPhone ? double.infinity : (MediaQuery.sizeOf(context).width / 1.5),
      builder: (ctx) => PostPreview(
        entity: widget.entity,
        markdown: widget.controller.text,
      ),
    );
  }

  /// 打开 post 设置
  void openPostSetting() {
    Get.showDrawer(
      stepWidth: Get.isPhone ? double.infinity : 60.0,
      builder: (ctx) => PostEditor(
        entity: widget.entity,
        picture: widget.picture,
      ),
    );
  }

  /// 获取标签符号的配置
  Config _getEmojiConfig() {
    // 表情符号配置
    return Config(
      emojiViewConfig: EmojiViewConfig(
        columns: 8,
        emojiSizeMax: 24,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      categoryViewConfig: CategoryViewConfig(
        tabBarHeight: 32,
        backgroundColor: theme.scaffoldBackgroundColor,
        indicatorColor: colorScheme.primary,
        iconColor: colorScheme.outlineVariant,
        iconColorSelected: colorScheme.primary,
        backspaceColor: colorScheme.primary,
      ),
      bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
    );
  }
}

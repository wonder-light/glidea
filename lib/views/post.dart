import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' show BottomActionBarConfig, CategoryViewConfig, Config, EmojiPicker, EmojiViewConfig;
import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, ExtensionDialog, Get, GetNavigationExt, Inst, Obx, RxBool, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/Common/visibility.dart';
import 'package:glidea/components/post/post_editor.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

/// 自定义控制器, 用于文本编辑器的字体样式显示
class CustomTextController extends TextEditingController {
  CustomTextController() : super() {
    _spanMaps = {
      //标题 /(#+)(.*)/g
      0: (reg: RegExp(r'(#+)(.*)'), match: _buildTitle),
      // 链接 /!?\[[\s\S]*?\]\([\s\S]*?\)/g
      1: (reg: RegExp(r'(!?\[)([\s\S]*?)(\]\([\s\S]*?\))'), match: _buildThreeSpan),
      // 粗体
      // 表示以一个 * 或者 _ 开头并结尾（\1表示规则和第一个集合相同）
      // (\\*\\*|__)(.*?)(\\1)
      2: (reg: RegExp(r'(\*\*|__)(.*?)(\1)'), match: (m) => _buildThreeSpan(m, style: _boldStyle, other: _titleStyle)),
      // 斜体
      // 表示以一个 * 或者 _ 开头并结尾（\1表示规则和第一个集合相同）
      // (\\*|_)(.*?)(\\1)
      3: (reg: RegExp(r'([*_])(.*?)(\1)'), match: (m) => _buildThreeSpan(m, style: _italicsStyle, other: _titleStyle)),
      // 引用块
      // \n(&gt;|\\>)(.*)
      4: (reg: RegExp(r'(\n[&gt;|>])(.*)'), match: (m) => _buildTitle(m, index: 1)),
      // 有序列表
      // ^[\\s]*[0-9]+\\.(.*)
      5: (reg: RegExp(r'(\s*[0-9]+\.)(\s*.*)'), match: (m) => _buildTitle(m, index: 1)),
      // 无序列表
      // ^[\\s]*[-\\*\\+] +(.*)
      6: (reg: RegExp(r'(\s*[-*+]\s+)(.*)'), match: (m) => _buildTitle(m, index: 1)),
      // 代码块
      // ```([\\s\\S]*?)```[\\s]?
      7: (reg: RegExp(r'(```)([\s\S]*?)(\1)'), match: (m) => _buildThreeSpan(m, style: _linkStyle, other: _titleStyle)),
      // 内联代码块
      // `{1,2}[^`](.*?)`{1,2}
      8: (reg: RegExp(r'(`{1,2}[^`])(.*?)(`{1,2})'), match: (m) => _buildThreeSpan(m, style: _linkStyle, other: _titleStyle)),
    };
  }

  TextStyle? _buildStyle;
  TextStyle? _titleStyle;
  TextStyle? _linkStyle;
  TextStyle? _italicsStyle;
  TextStyle? _boldStyle;
  late final Map<int, TSpanMatch> _spanMaps;

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // TODO: 改善编辑器性能
    final bool composingRegionOutOfRange = !value.isComposingRangeValid || !withComposing;
    if (!composingRegionOutOfRange) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    _buildStyle = style;
    _titleStyle = style?.copyWith(color: Colors.cyan);
    _linkStyle = style?.copyWith(color: Colors.black38);
    _italicsStyle = style?.copyWith(fontStyle: FontStyle.italic);
    _boldStyle = style?.copyWith(fontWeight: FontWeight.w700);
    return TextSpan(children: _buildTextSpan(value: text));
  }

  /// 构建 [TextSpan]
  List<TextSpan> _buildTextSpan({required String value, int index = 0}) {
    if (value.isEmpty) return [];
    // 没有规则, 之间返回
    if (index >= _spanMaps.length) {
      return [TextSpan(text: value, style: _buildStyle)];
    }
    assert(_spanMaps[index] != null, 'build TextSpan error, spanMaps[index] is null');
    // 使用下一个规则
    var spanMap = _spanMaps[index]!;
    return value.splitMapWithSep(
      pattern: spanMap.reg,
      onMatch: spanMap.match,
      onNonMatch: (str) => TextSpan(children: _buildTextSpan(value: str, index: index + 1)),
    );
  }

  TextSpan _buildTitle(Match match, {int index = 0}) {
    if (index <= 0) {
      return TextSpan(text: match[index], style: _titleStyle);
    } else {
      return TextSpan(children: [
        TextSpan(text: match[index], style: _titleStyle),
        TextSpan(text: match[index + 1], style: _buildStyle),
      ]);
    }
  }

  TextSpan _buildThreeSpan(Match match, {TextStyle? style, TextStyle? other}) {
    return TextSpan(children: [
      TextSpan(text: match[1], style: other ?? _linkStyle),
      TextSpan(text: match[2], style: style ?? _buildStyle),
      TextSpan(text: match[3], style: other ?? _linkStyle),
    ]);
  }
}

/// post 文件编辑页面
class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 获取的当前 post 数据
  late Post postData;

  /// 用于进行修改的 [postData] 副本
  late Post currentPost;

  /// 初始 post 内容
  String initContent = '';

  /// 判断是否禁用保存图标
  final isDisable = false.obs;

  /// 是否显示表情
  final isShowEmoji = false.obs;

  /// emoji, stats 中当前使用的 bool
  RxBool? currentBool;

  /// 标题的字段控制器
  final titleController = TextEditingController();

  /// 标题的字段控制器
  final contentController = CustomTextController();

  /// 右侧的工具栏按钮
  final List<TActionData> toolbars = [];

  /// 上下文菜单内容
  final List<TActions> contextMenus = [];

  /// head 上的操作按钮
  final List<TCallData> actions = [];

  /// 表情符号配置
  late final Config emojiConfig = _getEmojiConfig();

  /// 图片配置
  final picture = PictureConfig();

  /// 标签符号页面的高度
  static const _emojiHeight = 350.0;

  @override
  void initState() {
    super.initState();
    updatePostData();
    updateContent();
    // 禁用
    updateDisable();
    // 工具栏按钮
    toolbars.addAll([
      //(name: '', call: showPostStats, icon: PhosphorIconsRegular.warningCircle),
      (name: Tran.insertEmoji, call: showEmoji, icon: PhosphorIconsRegular.smiley),
      (name: Tran.insertImage, call: insertImage, icon: PhosphorIconsRegular.image),
      (name: Tran.insertMore, call: insertSeparator, icon: PhosphorIconsRegular.dotsThreeOutline),
      (name: Tran.postSettings, call: openPostSetting, icon: PhosphorIconsRegular.gear),
      (name: Tran.preview, call: previewPost, icon: PhosphorIconsRegular.eye),
    ]);
    // 上下文菜单
    contextMenus.addAll([]);
    //head 上的操作按钮
    actions.addAll([
      (call: backToArticlePage, dis: backToArticlePage, icon: PhosphorIconsRegular.arrowLeft, color: null, msg: Tran.back),
      (call: saveAsDraft, dis: null, icon: PhosphorIconsRegular.check, color: null, msg: Tran.saveDraft),
      (call: savePost, dis: null, icon: PhosphorIconsRegular.check, color: Get.theme.colorScheme.primary, msg: Tran.save),
    ]);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    isDisable.dispose();
    isShowEmoji.dispose();
    toolbars.clear();
    contextMenus.clear();
    actions.clear();
    site.off(themeSaveEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 内容
    Widget childWidget = Expanded(
      // 滚动
      child: SingleChildScrollView(
        child: _buildInputField(isRich: true),
      ),
    );
    // 标题
    childWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题
        _buildInputField(),
        // 内容
        childWidget,
      ],
    );
    // 工具栏
    childWidget = Stack(
      children: [
        childWidget,
        _buildToolbar(),
        _buildEmojiView(),
      ],
    );
    // 布局
    return Listener(
      onPointerDown: onPointerDown,
      child: PageAction(
        contentPadding: EdgeInsets.zero,
        actions: [
          for (var item in actions)
            TipWidget.down(
              message: item.msg.tr,
              child: Obx(
                () => IconButton(
                  onPressed: isDisable.value ? item.dis : item.call,
                  icon: Icon(item.icon, color: isDisable.value ? null : item.color),
                ),
              ),
            ),
        ],
        child: childWidget,
      ),
    );
  }

  /// 构建字段
  Widget _buildInputField({bool isRich = false}) {
    final theme = Get.theme;
    final textTheme = theme.textTheme;
    final style = isRich ? textTheme.bodyLarge : textTheme.titleLarge;
    return FractionallySizedBox(
      widthFactor: 0.7,
      alignment: Alignment.center,
      child: TextFormField(
        controller: isRich ? contentController : titleController,
        style: style,
        maxLines: isRich ? null : 1,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: kVer8Hor12,
          // 悬停时的背景色
          hoverColor: Colors.transparent,
          fillColor: Colors.transparent,
          focusColor: Colors.transparent,
          border: InputBorder.none,
          hintText: isRich ? Tran.startWriting.tr : Tran.title.tr,
          hintStyle: style?.copyWith(color: theme.colorScheme.outlineVariant),
        ),
        onChanged: (str) {
          if (!isRich) {
            currentPost.title = str;
          }
          updateDisable();
        },
        contextMenuBuilder: isRich ? _builderContextMenu : null,
      ),
    );
  }

  // 构建工具栏
  Widget _buildToolbar() {
    final colorScheme = Get.theme.colorScheme;
    Widget widget = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
    return Positioned(
      right: 16,
      top: 0,
      bottom: 0,
      child: widget,
    );
  }

  /// 构建表情控件
  Widget _buildEmojiView() {
    final colorScheme = Get.theme.colorScheme;
    Widget child = Obx(() {
      // 动画
      return AnimatedVisibility(
        visible: isShowEmoji.value,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: colorScheme.outlineVariant,
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
            border: Border.fromBorderSide(BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
          ),
          constraints: const BoxConstraints.expand(width: _emojiHeight - 30, height: _emojiHeight),
          child: EmojiPicker(
            onEmojiSelected: (category, emojis) => insertSeparator(separator: emojis.emoji),
            config: emojiConfig,
          ),
        ),
      );
    });
    // 加上位置
    return Positioned(
      right: 80,
      top: 0,
      bottom: 0,
      child: Align(
        alignment: Alignment.center,
        child: _wrapperMouse(
          child: child,
          value: isShowEmoji,
        ),
      ),
    );
  }

  /// 包装鼠标事件
  Widget _wrapperMouse({required Widget child, RxBool? value}) {
    return MouseRegion(
      onEnter: (event) => currentBool = null,
      onExit: (event) => currentBool = value,
      child: child,
    );
  }

  /// 上下文菜单
  Widget _builderContextMenu(BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: [
        ...AdaptiveTextSelectionToolbar.getAdaptiveButtons(context, editableTextState.contextMenuButtonItems),
        //const Divider(height: 1, thickness: 1),
      ],
    );
  }

  /// 返回 article 页面
  void backToArticlePage() {
    // 相同则返回
    if (site.equalPost(postData, currentPost)) {
      Get.toNamed(AppRouter.articles);
      return;
    }
    // 弹窗确认
    Get.dialog(DialogWidget(
      content: Padding(
        padding: kAllPadding16,
        child: Text(Tran.unsavedWarning.tr),
      ),
      onCancel: () {
        // 关闭弹窗
        Get.closeAllDialogs();
      },
      onConfirm: () {
        // 返回首页
        Get.toNamed(AppRouter.articles);
      },
    ));
  }

  /// 存草稿 post
  void saveAsDraft() {
    savePost(published: false);
  }

  /// 保存 post
  void savePost({bool published = true}) async {
    // 看 fileName 是否包含 '/'
    if (currentPost.fileName.contains('/')) {
      Get.error(Tran.postUrlIncludeTip);
      return;
    }
    // 检测 post 是否可以保存
    if (!site.checkPost(currentPost, postData) && contentController.text.isNotEmpty) {
      Get.error(Tran.postUrlRepeatTip);
      return;
    }
    currentPost.published = published;
    await site.emit(themeSaveEvent);
    site.updatePost(newData: currentPost, oldData: postData, fileContent: contentController.text).then((value){
      value ? Get.success(published ? Tran.saved : Tran.draftSuccess): Get.error(Tran.saveError);
    });
    // 更新数据
    setState(() => updatePostData());
  }

  /// 预览 post
  void previewPost() {
    openPostSetting(preview: true);
  }

  /// 打开 post 设置
  void openPostSetting({bool preview = false}) {
    var width = !preview ? null : MediaQuery.sizeOf(context).width / 1.5;
    var stepWidth = 60.0;
    if (Get.isPhone) {
      width = null;
      stepWidth = double.infinity;
    }
    Get.showDrawer(
      stepWidth: stepWidth,
      width: width,
      builder: (ctx) => PostEditor(
        preview: preview,
        header: preview ? '' : Tran.postSettings.tr,
        entity: currentPost,
        markdown: preview ? contentController.text : '',
        picture: picture,
      ),
    );
  }

  /// 插入分隔符
  void insertSeparator({String separator = summarySeparator}) {
    // 位置
    var selection = contentController.selection;
    // 内容
    var content = contentController.text;
    // 位置
    var end = selection.end;
    // 文本为空
    if (selection.start < 0 && selection.end < 0) {
      end = 0;
    }
    // 插入摘要分隔符
    contentController.text = '${content.substring(0, end)}$separator${content.substring(end)}';
    // 复原位置
    contentController.selection = TextSelection.collapsed(offset: end + separator.length);
  }

  /// 插入图片
  void insertImage() async {
    //实例化选择图片
    FilePickerResult? result = await FilePicker.platform.pickFiles(
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

  /// 显示表情符号
  void showEmoji() {
    if (currentBool == isShowEmoji) return;
    isShowEmoji.value = !isShowEmoji.value;
    currentBool = isShowEmoji;
  }

  /// 显示 post 统计信息
  void showPostStats() {}

  /// 更新 post 数据
  void updatePostData() {
    // 获取已有的数据或者新的数据
    postData = site.getPostOrDefault(Get.arguments as String);
    // 复制
    currentPost = postData.copy<Post>()!;
    titleController.text = currentPost.title;
    picture.value = postData.feature;
  }

  /// 从文件读取内容
  Future<void> updateContent() async {
    final path = FS.join(site.state.appDir, 'posts', '${currentPost.fileName}.md');
    initContent = FS.fileExistsSync(path) ? await FS.readString(path) : '';
    contentController.text = initContent;
  }

  /// 更新保存按钮是否禁用
  void updateDisable() {
    isDisable.value = currentPost.title.isEmpty || initContent == contentController.text;
  }

  /// 鼠标点击事件, 用于关闭 emoji, stats 视图
  void onPointerDown(PointerEvent event) {
    if (currentBool?.value == true) {
      currentBool?.value = false;
      return;
    }
    currentBool = null;
  }

  /// 获取标签符号的配置
  Config _getEmojiConfig() {
    // 表情符号配置
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    return Config(
      height: _emojiHeight,
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

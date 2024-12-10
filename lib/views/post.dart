import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/drawer.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/post/post_editor.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/post.dart';
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
  late final RxObject<Post> postData;

  /// 用于进行修改的 [postData] 副本
  late final RxObject<Post> currentPost;

  /// 标题的字段控制器
  final titleController = TextEditingController();

  /// 标题的字段控制器
  final contentController = CustomTextController();

  /// 顶部的操作按钮
  final List<TActionData> actionButtons = [];

  /// 右侧的工具栏按钮
  final List<TActionData> toolbars = [];

  @override
  void initState() {
    super.initState();
    final fileName = Get.arguments as String;
    // 获取已有的数据或者新的数据
    postData = site.getPostOrDefault(fileName).obs;
    // 复制
    currentPost = postData.value.copy<Post>()!.obs;
    titleController.text = currentPost.value.title;
    contentController.text = currentPost.value.content;
    // 操作按钮
    actionButtons.addAll([
      (name: 'back', call: backToArticlePage, icon: PhosphorIconsRegular.arrowLeft),
      (name: 'saveDraft', call: saveAsDraft, icon: PhosphorIconsRegular.check),
      (name: 'save', call: savePost, icon: PhosphorIconsRegular.check),
    ]);
    // 工具栏按钮
    toolbars.addAll([
      (name: '', call: showPostStats, icon: PhosphorIconsRegular.warningCircle),
      (name: 'insertEmoji', call: insertEmoji, icon: PhosphorIconsRegular.smiley),
      (name: 'insertImage', call: insertImage, icon: PhosphorIconsRegular.image),
      (name: 'insertMore', call: insertSeparator, icon: PhosphorIconsRegular.dotsThreeOutline),
      (name: 'postSettings', call: openPostSetting, icon: PhosphorIconsRegular.gear),
      (name: 'preview', call: previewPost, icon: PhosphorIconsRegular.eye),
    ]);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    postData.dispose();
    currentPost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    // 内容
    Widget content = Expanded(
      // 滚动
      child: SingleChildScrollView(
        child: _buildInputField(isRich: true),
      ),
    );
    // 布局
    return PageAction(
      contentPadding: EdgeInsets.zero,
      actions: [
        for (var item in actionButtons)
          IconButton(
            onPressed: item.call,
            icon: Icon(item.icon, color: item.name == 'save' ? colorScheme.primary : null),
            tooltip: item.name.tr,
          ),
      ],
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              _buildInputField(),
              // 内容
              content,
            ],
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  /// 构建字段
  Widget _buildInputField({bool isRich = false}) {
    final theme = Get.theme;
    final textTheme = theme.textTheme;
    final style = isRich ? textTheme.bodyLarge : textTheme.titleLarge;
    Widget widget = FractionallySizedBox(
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
          hintText: isRich ? 'startWriting'.tr : 'title'.tr,
          hintStyle: style?.copyWith(color: theme.colorScheme.outlineVariant),
        ),
        onChanged: (str) => isRich ? currentPost.value.content = str : currentPost.value.title = str,
      ),
    );
    /*if (isRich) {
      widget = Expanded(child: widget);
    }*/
    return widget;
  }

  // 构建工具栏
  Widget _buildToolbar() {
    final colorScheme = Get.theme.colorScheme;
    Widget widget = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var item in toolbars)
          // TODO: 悬浮提示设置水平偏移
          IconButton(
            onPressed: item.call,
            icon: Icon(item.icon, color: colorScheme.outlineVariant),
            //tooltip: item.name.tr,
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

  /// 返回 article 页面
  void backToArticlePage() {
    // 相同则返回
    if (site.equalPost(postData.value, currentPost.value)) {
      Get.toNamed(AppRouter.articles);
    }
    // 弹窗确认
    Get.dialog(DialogWidget(
      content: Padding(
        padding: kAllPadding16,
        child: Text('unsavedWarning'.tr),
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
  void savePost({bool published = true}) {
    currentPost.value.published = published;
    site.updatePost(newData: currentPost.value, oldData: postData.value);
  }

  /// 预览 post
  void previewPost() {
    openPostSetting(preview: true);
  }

  /// 打开 post 设置
  void openPostSetting({bool preview = false}) {
    /// 抽屉控制器
    final drawerController = DraController();
    Get.showDrawer(
      width: preview ? Get.width / 1.75 : null,
      controller: drawerController,
      builder: (ctx) => PostEditor(
        preview: preview,
        header: preview ? '' : 'postSettings',
        entity: postData.value,
        markdown: contentController.text,
        controller: drawerController,
      ),
    );
  }

  /// 插入分隔符
  void insertSeparator() {
    // 内容
    final content = contentController.text;
    // 位置
    final end = contentController.selection.end;
    // 插入摘要分隔符
    contentController.text = '${content.substring(0, end)}$summarySeparator${content.substring(end)}';
  }

  /// 插入图片
  void insertImage() {}

  /// 插入表情符号
  void insertEmoji() {}

  /// 显示 post 统计信息
  void showPostStats() {}
}

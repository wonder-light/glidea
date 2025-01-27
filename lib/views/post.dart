import 'dart:async' show Completer;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show BoolExtension, ExtensionDialog, Get, GetNavigationExt, Inst, Obx, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/components/Common/loading.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/components/post/content.dart';
import 'package:glidea/components/post/toolbar.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;
import 'package:re_editor/re_editor.dart' show CodeLineEditingController, CodeLines;

// 高亮样式可以看这个 https://highlightjs.org/demo

/// post 文件编辑页面
class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 控制的初始化任务
  final initTask = Completer();

  /// 当前 post 的 fileName
  late String _fileName;

  /// 获取的当前 post 数据
  late Post postData;

  /// 用于进行修改的 [postData] 副本
  late Post currentPost;

  /// 初始 post 内容
  CodeLines _initContent = CodeLines.empty();

  /// 判断是否禁用保存图标
  final isDisable = false.obs;

  /// 标题的字段控制器
  final titleCtr = TextEditingController();

  /// 标题的字段控制器
  final contentCtr = CodeLineEditingController();

  /// 主题数据
  late final theme = Theme.of(context);

  /// head 上的操作按钮
  late final List<TCallData> actions = [
    (call: backToArticlePage, dis: backToArticlePage, icon: PhosphorIconsRegular.arrowLeft, color: null, msg: Tran.back),
    (call: saveAsDraft, dis: null, icon: PhosphorIconsRegular.check, color: null, msg: Tran.saveDraft),
    (call: savePost, dis: null, icon: PhosphorIconsRegular.check, color: theme.colorScheme.primary, msg: Tran.save),
  ];

  /// 图片配置
  final picture = PictureConfig();

  @override
  void initState() {
    super.initState();
    _fileName = Get.arguments;
    onInitData();
  }

  @override
  void dispose() {
    titleCtr.dispose();
    contentCtr.dispose();
    isDisable.dispose();
    actions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 主体
    Widget child = FutureBuilder(
      future: initTask.future,
      builder: (ctx, snapshot) {
        // 加载
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LoadingWidget());
        }
        // 标题
        Widget childWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
            _buildInputField(),
            // 内容
            Expanded(child: PostContent(controller: contentCtr)),
          ],
        );
        // 工具栏
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            FractionallySizedBox(widthFactor: 0.7, alignment: Alignment.center, child: childWidget),
            PostToolbar(entity: currentPost, picture: picture, controller: contentCtr),
          ],
        );
      },
    );
    // 顶部工具栏
    child = PageWidget(
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
      child: child,
    );
    // 安全面板
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(child: child),
    );
  }

  /// 构建字段
  Widget _buildInputField() {
    final style = theme.textTheme.titleLarge;
    return TextFormField(
      controller: titleCtr,
      style: style,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVerPadding16,
        // 悬停时的背景色
        hoverColor: Colors.transparent,
        fillColor: Colors.transparent,
        focusColor: Colors.transparent,
        border: InputBorder.none,
        hintText: Tran.title.tr,
        hintStyle: style?.copyWith(color: theme.colorScheme.outlineVariant),
      ),
      onChanged: (str) => isDisable.value = (currentPost.title = str).isEmpty,
    );
  }

  /// 返回 article 页面
  void backToArticlePage() {
    // 相同则返回
    if (site.equalPost(postData, currentPost) && _initContent == contentCtr.codeLines) {
      Get.toNamed(AppRouter.articles);
      return;
    }
    // 弹窗确认
    Get.dialog(DialogWidget(
      content: Padding(padding: kAllPadding16, child: Text(Tran.unsavedWarning.tr)),
      // 关闭弹窗
      onCancel: () => Get.closeAllDialogs(),
      // 返回首页
      onConfirm: () => Get.toNamed(AppRouter.articles),
    ));
  }

  /// 存草稿 post
  void saveAsDraft() => savePost(published: false);

  /// 保存 post
  void savePost({bool published = true}) async {
    // 看 fileName 是否包含 '/'
    if (currentPost.fileName.contains('/')) {
      Get.error(Tran.postUrlIncludeTip);
      return;
    }
    // 检测 post 是否可以保存
    if (!site.checkPost(currentPost, postData)) {
      Get.error(Tran.postUrlRepeatTip);
      return;
    }
    // 发布或存草稿
    currentPost.published = published;
    final pict = picture.filePath.isEmpty || picture.filePath.contains(picture.value) ? null : picture;
    final value = await site.updatePost(newData: currentPost, oldData: postData, fileContent: contentCtr.text, picture: pict);
    if (value) {
      Get.success(published ? Tran.saved : Tran.draftSuccess);
      _fileName = currentPost.fileName;
      // 更新数据
      setState(updatePostData);
    } else {
      Get.error(Tran.saveError);
    }
  }

  /// 用于在开始时初始化数据
  Future<void> onInitData() async {
    updatePostData();
    await updateContent();
    // 更新禁用
    isDisable.value = currentPost.title.isEmpty;
    // 完成
    initTask.complete();
  }

  /// 更新 post 数据
  void updatePostData() {
    // 获取已有的数据或者新的数据
    postData = site.getPostOrDefault(_fileName);
    // 复制
    currentPost = postData.copy<Post>()!;
    titleCtr.text = currentPost.title;
    picture
      ..value = postData.feature
      ..filePath = '';
    // 设置内容的初始值, 在 [setState] 中覆盖
    _initContent = contentCtr.codeLines;
  }

  /// 从文件读取内容
  Future<void> updateContent() async {
    final path = FS.join(site.state.appDir, 'posts', '${currentPost.fileName}.md');
    contentCtr.text = FS.fileExistsSync(path) ? await FS.readString(path) : '';
    // 只在 [initState] 中覆盖
    _initContent = contentCtr.codeLines;
  }
}

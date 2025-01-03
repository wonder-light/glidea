﻿import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/page_action.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/routes/router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class ArticlesView extends StatefulWidget {
  const ArticlesView({super.key});

  @override
  State<ArticlesView> createState() => _ArticlesViewState();
}

class _ArticlesViewState extends State<ArticlesView> {
  /// 筛选文章的文本内容
  final filterText = ''.obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 文章搜索控制器
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        MediaQuery(
          data: Get.mediaQuery.copyWith(textScaler: const TextScaler.linear(0.8)),
          child: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              hoverColor: Colors.transparent,
              // 悬停时的背景色
              constraints: const BoxConstraints(maxWidth: kPanelWidth, minHeight: 0),
              contentPadding: kVerPadding8 + kHorPadding16,
              suffixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
              // 覆盖 suffixIcon 的约束
              suffixIconConstraints: const BoxConstraints(minWidth: kMinInteractiveDimension),
              labelText: Tran.searchArticle.tr,
            ),
            onChanged: searchPost,
          ),
        ),
        TipWidget.down(
          message: Tran.newArticle.tr,
          child: IconButton(
            onPressed: addNewPost,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ),
      ],
      child: Obx(
        () {
          final filterPosts = site.filterPost(filterText.value);
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return _buildListItem(filterPosts[index]);
            },
            itemCount: filterPosts.length,
            separatorBuilder: (BuildContext context, int index) {
              return Container(height: listSeparated);
            },
          );
        },
      ),
    );
  }

  /// 构建菜单项
  Widget _buildListItem(Post post) {
    // 主题配置
    final ThemeData(:textTheme, :colorScheme) = Get.theme;

    /// 判断是否是手机端
    final isDesktop = !Get.isPhone;

    // 子列表
    final lists = <TIconData>[
      // 发布
      post.published ? (name: Tran.published, icon: PhosphorIconsRegular.check) : (name: Tran.draft, icon: PhosphorIconsRegular.x),
      // 日期
      (name: post.date.format(pattern: site.themeConfig.dateFormat), icon: PhosphorIconsRegular.calendarDots),
    ];

    // 头部组件
    final leading = isDesktop ? ImageConfig.builderImg(site.getFeaturePath(post)) : null;

    //内容边距
    final contentPadding = isDesktop ? kRightPadding16 : null;

    // 大小
    final constraints = isDesktop ? const BoxConstraints(maxHeight: 80) : const BoxConstraints(minHeight: 100);

    return ListItem(
      shape: ContinuousRectangleBorder(
        side: BorderSide(
          color: colorScheme.onSurface,
          width: 0.15,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: contentPadding,
      constraints: constraints,
      leading: leading,
      title: Text(post.title),
      subtitle: Wrap(
        spacing: kRightPadding4.right,
        children: [
          for (var item in lists) ...[
            Icon(item.icon),
            Padding(
              padding: kRightPadding4,
              child: Text(item.name.tr),
            ),
          ],
          if (post.tags.isNotEmpty) ...[
            const Icon(PhosphorIconsRegular.tag),
            for (var tag in post.tags) Text(tag.name),
          ],
        ],
      ),
      trailing: IconButton(
        onPressed: () => deletePost(post),
        icon: const Icon(PhosphorIconsRegular.trash),
      ),
      onTap: () => editorPost(fileName: post.fileName),
    );
  }

  /// 添加文章
  void addNewPost() {
    editorPost();
  }

  /// 编辑文章
  void editorPost({String fileName = ''}) {
    Get.toNamed(AppRouter.post, arguments: fileName);
  }

  /// 删除文章
  void deletePost(Post post) {
    // 弹窗
    Get.dialog(DialogWidget(
      onCancel: () {
        Get.backLegacy();
      },
      onConfirm: () {
        site.removePost(post);
        Get.backLegacy();
      },
    ));
  }

  /// 搜索文章
  void searchPost(String str) {
    filterText.value = str;
  }
}

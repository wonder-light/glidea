import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxT, Trans;
import 'package:glidea/components/ListItem.dart';
import 'package:glidea/components/pageAction.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/interfaces/types.dart';
import 'package:glidea/models/post.dart';
import 'package:jiffy/jiffy.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class ArticlesWidget extends StatefulWidget {
  const ArticlesWidget({super.key});

  @override
  State<ArticlesWidget> createState() => _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<ArticlesWidget> {
  /// 需要删除的文章
  final deletePosts = [].obs;

  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  /// 文章搜索控制器
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.addListener(searchPost);
  }

  @override
  Widget build(BuildContext context) {
    return PageAction(
      actions: [
        TextFormField(
          controller: textController,
          decoration: const InputDecoration(
            isDense: true,
            constraints: BoxConstraints(maxWidth: 150),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            hoverColor: Colors.transparent, // 悬停时的背景色
          ),
        ),
        IconButton(
          onPressed: addNewPost,
          icon: const Icon(PhosphorIconsRegular.plus),
          tooltip: 'newTag'.tr,
        ),
      ],
      child: Obx(
        () => ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return _buildListItem(site.posts[index]);
          },
          itemCount: site.posts.length,
          separatorBuilder: (BuildContext context, int index) {
            return Container(height: 10);
          },
        ),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildListItem(Post post) {
    // 主题配置
    final ThemeData(:textTheme, :colorScheme) = Get.theme;

    /// 判断是否是桌面端
    final isDesktop = Get.isDesktop;

    // 子列表
    final lists = <TIconData>[
      // 发布
      if (post.published) (name: 'published', icon: PhosphorIconsRegular.check) else (name: 'draft', icon: PhosphorIconsRegular.x),
      // 日期
      (name: Jiffy.parse(post.date).format(pattern: site.themeConfig.dateFormat), icon: PhosphorIconsRegular.calendarDots),
    ];

    // 头部组件
    final leading = isDesktop
        ? Image.file(
            File(site.getFeaturePath(data: post)),
            fit: BoxFit.cover,
            height: double.infinity,
          )
        : null;

    //内容边距
    final contentPadding = isDesktop ? const EdgeInsets.only(right: 16) : null;

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
      title: Text(
        post.title,
      ),
      subtitle: Row(
        children: [
          for (var item in lists) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(item.icon),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(item.name.tr),
            ),
          ],
          if (post.tags.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(PhosphorIconsRegular.tag),
            ),
            for (var tag in post.tags)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(tag.name),
              ),
          ],
        ],
      ),
      trailing: IconButton(
        onPressed: () => deletePost(post),
        icon: const Icon(PhosphorIconsRegular.trash),
      ),
      onTap: () => editorPost(post),
    );
  }

  /// 添加文章
  void addNewPost() {
    editorPost(site.createPost());
  }

  /// 编辑文章
  void editorPost(Post post) {}

  /// 删除文章
  void deletePost(Post post) {}

  /// 搜索文章
  void searchPost() {}
}

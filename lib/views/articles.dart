import 'package:flutter/material.dart';
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigationExt, Inst, Obx, StringExtension, Trans;
import 'package:glidea/components/Common/dialog.dart';
import 'package:glidea/components/Common/group.dart';
import 'package:glidea/components/Common/list_item.dart';
import 'package:glidea/components/Common/tip.dart';
import 'package:glidea/controller/site/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/image.dart';
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

  /// 判断是否是手机端
  final isDesktop = !Get.isPhone;

  // 主题配置
  late final theme = Theme.of(context);
  late final textTheme = theme.textTheme;
  late final colorScheme = theme.colorScheme;

  /// 记录时间
  final Map<int, String> dates = {};

  // 形状
  late final shapeBorder = ContinuousRectangleBorder(
    side: BorderSide(
      color: colorScheme.onSurface,
      width: 0.15,
    ),
    borderRadius: BorderRadius.circular(10.0),
  );

  @override
  Widget build(BuildContext context) {
    final padding = kVerPadding4 * 1.25;
    return PageWidget(
      contentPadding: kAllPadding16,
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
      child: Obx(() {
        final filterPosts = site.filterPost(filterText.value);
        return ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return _buildListItem(filterPosts[index]);
          },
          itemCount: filterPosts.length,
          separatorBuilder: (BuildContext context, int index) => Padding(padding: padding),
        );
      }),
    );
  }

  /// 构建菜单项
  Widget _buildListItem(Post post) {
    // 大小
    final constraints = BoxConstraints(maxHeight: isDesktop ? 80 : 100);
    // 时间
    final date = dates[post.date.millisecondsSinceEpoch] ??= post.date.format(pattern: site.themeConfig.dateFormat);
    // 头部组件
    var child = ImageConfig.builderImg(site.getFeaturePath(post), aspectRatio: 1.775);
    // 项
    child = ListItem(
      shape: shapeBorder,
      contentPadding: kRightPadding16,
      constraints: constraints,
      leading: child,
      title: Text(post.title),
      subtitle: Wrap(
        spacing: kRightPadding4.right,
        children: [
          Icon(PhosphorIconsRegular.check, color: post.published ? colorScheme.primary : null),
          Text(post.published ? Tran.published.tr : Tran.draft.tr),
          const Icon(PhosphorIconsRegular.calendarDots),
          Text(date),
          if (post.tags.isNotEmpty) const Icon(PhosphorIconsRegular.tag),
          if (post.tags.isNotEmpty)
            for (var tag in site.getTagsWithPost(post)) Text(tag.name),
        ],
      ),
      trailing: IconButton(
        onPressed: () => deletePost(post),
        icon: const Icon(PhosphorIconsRegular.trash),
      ),
      onTap: () => editorPost(fileName: post.fileName),
    );
    // 构建右上角的图标
    if (post.isTop || post.hideInList) {
      child = Stack(
        children: [
          child,
          if (post.hideInList) _buildBadge(right: post.isTop ? 40 : 0, text: 'HIDE'),
          if (post.isTop) _buildBadge(color: colorScheme.secondaryContainer),
        ],
      );
    }
    return child;
  }

  /// 构建右上角的图标
  Widget _buildBadge({double right = 0, Color? color, String text = 'TOP'}) {
    return Positioned(
      top: 0,
      right: right,
      child: Container(
        padding: kHorPadding8 / 2,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: color ?? theme.colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(text, style: textTheme.bodySmall),
      ),
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
      onCancel: () => Get.backLegacy(),
      onConfirm: () async {
        final value = await site.removePost(post);
        value ? Get.success(Tran.articleDelete) : Get.error(Tran.articleDeleteFailure);
        Get.backLegacy();
      },
    ));
  }

  /// 搜索文章
  void searchPost(String str) {
    filterText.value = str;
  }
}

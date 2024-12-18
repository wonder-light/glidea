import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/render/array.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
import 'package:markdown_widget/markdown_widget.dart' show MarkdownConfig, MarkdownGenerator, MarkdownWidget;
import 'package:omni_datetime_picker/omni_datetime_picker.dart' show showOmniDateTimePicker;
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

/// 文章设置编辑器, 文章预览
class PostEditor extends DrawerEditor<Post> {
  const PostEditor({
    super.key,
    required super.entity,
    super.controller,
    super.header = Tran.postSettings,
    super.showAction = false,
    this.preview = true,
    this.markdown,
    required this.picture,
  });

  /// 预览 post 文章
  final bool preview;

  /// markdown 内容
  final String? markdown;

  final PictureConfig picture;

  @override
  PostEditorState createState() => PostEditorState();
}

class PostEditorState extends DrawerEditorState<PostEditor> {
  late final expansions = <({Widget Function() build, bool expanded, String header})>[].obs;

  /// 日期的控制器
  TextEditingController? dateController;

  /// 是否是隐藏的
  final isHide = false.obs;

  /// 是否是置顶的
  final isTop = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.preview) return;
    final post = widget.entity;
    expansions.value.addAll([
      (expanded: true, build: _buildUrl, header: 'URL'),
      (expanded: false, build: _buildDate, header: Tran.createAt),
      (expanded: false, build: _buildTags, header: Tran.tag),
      (expanded: false, build: _buildImage, header: Tran.featureImage),
      (expanded: false, build: _buildHide, header: Tran.hideInList),
      (expanded: false, build: _buildTop, header: Tran.topArticles),
    ]);
    dateController = TextEditingController(text: post.date.format(pattern: site.themeConfig.dateFormat));
    isHide.value = post.hideInList;
    isTop.value = post.isTop;
  }

  @override
  void dispose() {
    dateController?.dispose();
    isHide.dispose();
    isTop.dispose();
    super.dispose();
  }

  @override
  List<Widget> buildContent(BuildContext context) {
    return [widget.preview ? _buildPreview() : _buildSetting()];
  }

  /// 构建预览
  Widget _buildPreview() {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final post = widget.entity;
    final dateStr = post.date.format(pattern: site.themeConfig.dateFormat);
    final dateStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.outline);
    // 控件
    final List<Widget> children = [
      ImageConfig.builderImg(site.getFeaturePath(widget.entity)),
      Text(post.title, style: textTheme.headlineSmall),
      Text(dateStr, style: dateStyle),
      if (post.tags.isNotEmpty)
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var tag in post.tags)
              Container(
                padding: kVerPadding4 + kHorPadding8,
                decoration: BoxDecoration(
                  color: colorScheme.onInverseSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(tag.name, style: textTheme.bodySmall),
              ),
          ],
        ),
      MarkdownWidget(
        data: widget.markdown ?? '',
        shrinkWrap: true,
        config: MarkdownConfig(configs: [
          const ImageConfig(),
        ]),
        markdownGenerator: MarkdownGenerator(
          extensionSet: Markdown.custom,
          textGenerator: CustomTextNode.new,
        ),
      ),
    ];
    // 返回
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: i <= 0 ? kTopPadding8 : kTopPadding16,
            child: children[i],
          ),
      ],
    );
  }

  /// 设置视图
  Widget _buildSetting() {
    var color = Get.theme.colorScheme.surfaceContainerHigh;
    return Obx(() {
      return ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (index, exp) {
          expansions.update((obj) {
            final tar = obj[index];
            obj[index] = (expanded: exp, build: tar.build, header: tar.header);
            return obj;
          });
        },
        children: [
          for (var item in expansions.value)
            ExpansionPanel(
              headerBuilder: (ctx, exp) => Padding(
                padding: kHorPadding16,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item.header.tr),
                ),
              ),
              body: Padding(padding: kHorPadding16, child: item.build()),
              isExpanded: item.expanded,
              canTapOnHeader: true,
              backgroundColor: item.expanded ? null : color,
            )
        ],
      );
    });
  }

  /// 设置中的 fileName
  Widget _buildUrl() {
    return TextFormField(
      initialValue: widget.entity.fileName,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
      ),
      onChanged: (str) {
        widget.entity.fileName = str;
      },
    );
  }

  /// 设置中的标签
  Widget _buildTags() {
    final slugSet = widget.entity.tags.map((t) => t.slug).toSet();
    return DropdownWidget(
      itemHeight: 40,
      enableSearch: true,
      enableFilter: true,
      enableHighlight: true,
      enableMultiple: true,
      initMultipleValue: site.tags.where((t) => slugSet.contains(t.slug)).toSet(),
      itemPadding: kHorPadding16,
      filterCallback: (tag, str) {
        return tag.name.contains(str);
      },
      displayStringForItem: (tag) => tag.name,
      children: [
        for (var tag in site.tags)
          DropdownMenuItem(
            value: tag,
            child: Text(tag.name),
          ),
      ],
      multipleCallback: (items) {
        widget.entity.tags = items.toList();
      },
    );
  }

  /// 设置中的日期
  Widget _buildDate() {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: kVer8Hor12,
        hoverColor: Colors.transparent, // 悬停时的背景色
        suffixIcon: IconButton(onPressed: openDatePicker, icon: const Icon(PhosphorIconsRegular.calendarDots)),
      ),
      readOnly: true,
    );
  }

  /// 图片
  Widget _buildImage() {
    final post = widget.entity;
    return ArrayWidget.create(
      config: widget.picture,
      randomName: true,
      onChanged: (str) => widget.entity.feature = str,
    );
  }

  /// 隐藏
  Widget _buildHide({bool top = false}) {
    final post = widget.entity;
    return Align(
      alignment: Alignment.centerLeft,
      child: Obx(() {
        final obj = top ? isTop : isHide;
        return Switch(
          value: obj.value,
          onChanged: (value) => obj.value = (top ? post.isTop = value : post.hideInList = value),
          trackOutlineWidth: WidgetStateProperty.all(0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }),
    );
  }

  /// 置顶
  Widget _buildTop() => _buildHide(top: true);

  /// 选择日期
  void openDatePicker() async {
    final date = widget.entity.date;
    final result = await showOmniDateTimePicker(
      context: context,
      is24HourMode: true,
      isShowSeconds: true,
      initialDate: date,
      firstDate: date.copyWith(year: date.year - 25),
      lastDate: date.copyWith(year: date.year + 25),
      constraints: const BoxConstraints(maxWidth: 400),
    );
    if (result != null) {
      widget.entity.date = result;
      dateController?.text = result.format(pattern: site.themeConfig.dateFormat);
    }
  }
}

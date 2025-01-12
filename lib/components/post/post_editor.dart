import 'package:flutter/material.dart';
import 'package:get/get.dart' show Obx, Trans, BoolExtension;
import 'package:glidea/components/Common/drawer_editor.dart';
import 'package:glidea/components/Common/dropdown.dart';
import 'package:glidea/components/render/base.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/date.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/lang/base.dart';
import 'package:glidea/models/post.dart';
import 'package:glidea/models/render.dart';
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
    required this.picture,
  });

  /// 图片配置
  final PictureConfig picture;

  @override
  PostEditorState createState() => PostEditorState();
}

class PostEditorState extends DrawerEditorState<PostEditor> {
  /// 扩展项
  late final expansions = <({ValueGetter<Widget> build, String header})>[
    (build: _buildUrl, header: 'URL'),
    (build: _buildDate, header: Tran.createAt),
    (build: _buildTags, header: Tran.tag),
    (build: _buildImage, header: Tran.featureImage),
    (build: _buildHide, header: Tran.hideInList),
    (build: _buildTop, header: Tran.topArticles),
  ];

  /// 日期的控制器
  TextEditingController? dateController;

  /// 是否是隐藏的
  final isHide = false.obs;

  /// 是否是置顶的
  final isTop = false.obs;

  @override
  void initState() {
    super.initState();
    final post = widget.entity;
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
  Widget? buildContent(BuildContext context, int index) {
    final item = expansions.elementAtOrNull(index);
    if (item == null) return null;
    // 项目
    return ExpansionTile(
      initiallyExpanded: item.header == 'URL',
      title: Text(item.header.tr),
      childrenPadding: kAllPadding16,
      children: [item.build()],
    );
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
    final slugSet = widget.entity.tags.toSet();
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
        widget.entity.tags = items.map((t) => t.slug).toList();
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
    return PictureWidget(
      constraints: const BoxConstraints(),
      config: widget.picture.obs,
      onChanged: saveImage,
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

  /// 保存图片
  void saveImage(dynamic str) async {
    //  /post-images/1292983484382.{jpg}
    final path = FS.join('/post-images', '${DateTime.now().millisecondsSinceEpoch}${FS.extension(widget.picture.filePath)}');
    // 设置
    widget.picture.value = path;
    widget.entity.feature = path;
    await site.saveThemeImage(widget.picture);
  }
}

import 'package:file_picker/file_picker.dart' show FilePicker, FilePickerResult, FileType;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxString, StringExtension;
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/events.dart';
import 'package:glidea/helpers/fs.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/image.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/markdown.dart';
import 'package:glidea/models/render.dart';
import 'package:image/image.dart' as img show decodeImageFile;

import 'base.dart';

typedef _TPathString = ({String initPath, String assetsPath, String dirPath});

/// 主题设置中的图片控件
class PictureWidget extends StatefulWidget {
  const PictureWidget({
    super.key,
    required this.config,
    this.isVertical = true,
    this.onChanged,
    this.randomName = false,
  });

  /// true: 标题在顶部
  ///
  /// false: 标题在前面
  final bool isVertical;

  /// 下拉列表配置
  ///
  /// [config.label] 需要手动添加 [i18n] 翻译
  final RxObject<PictureConfig> config;

  /// 当值发生变化时调用 - 主要用于 ArrayWidget 中接收值的变化
  final ValueChanged<dynamic>? onChanged;

  /// 是否自动重命名
  final bool randomName;

  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

class _PictureWidgetState extends State<PictureWidget> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  // 当前图片路径
  final path = ''.obs;

  /// 事件 ID
  late String eventId = _getId();

  /// 路径数据
  late _TPathString pathData = _getFilePath();

  @override
  void initState() {
    super.initState();
    _recordPath();
    // 绑定事件, 以路径作为 id, 防止重复
    site.once(themeSaveEvent, _saveImage, id: eventId, cover: true);
  }

  @override
  void didUpdateWidget(covariant PictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      eventId = _getId();
      pathData = _getFilePath();
      _recordPath();
    }
  }

  @override
  void dispose() {
    path.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 颜色
    final colorScheme = Get.theme.colorScheme;
    // 控件
    return ConfigLayoutWidget(
      isVertical: widget.isVertical,
      config: widget.config.value,
      child: OutlinedButton(
        onPressed: () => changeImage(path),
        style: ButtonStyle(
          enableFeedback: true,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: WidgetStateProperty.all(kAllPadding16 / 2),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            var color = states.contains(WidgetState.hovered) ? colorScheme.outline : colorScheme.outlineVariant;
            return BorderSide(color: color, width: 0.4);
          }),
        ),
        child: ConstrainedBox(
          constraints: site.isThemeCustomPage == null
              ? const BoxConstraints()
              : const BoxConstraints(
                  minWidth: kImageWidth / 1.5,
                  maxWidth: kImageWidth,
                  maxHeight: kImageWidth * 2,
                ),
          child: Obx(() => ImageConfig.builderImg(path.value, fit: BoxFit.contain)),
        ),
      ),
    );
  }

  /// 改变图片
  void changeImage(RxString path) async {
    /*
    //实例化选择图片
    final picker = ImagePicker();
    //选择相册
    final pickerImages = await picker.pickImage(source: ImageSource.gallery);
    if (pickerImages == null || pickerImages.path.isEmpty) return;
    */
    //实例化选择图片
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: imageExt,
    );
    if (result?.paths.firstOrNull?.isEmpty ?? true) return;
    // 选择的图片路径
    path.value = FS.normalize(result!.paths.first!);
    widget.config.value.filePath = path.value;
  }

  /// 更新 config
  void updateObj(String path) {
    widget.config.update((obj) => obj..value = path);
    widget.onChanged?.call(path);
  }

  /// 记录路径
  void _recordPath() {
    final config = widget.config.value;
    // 设置记录的初始值
    if (config.filePath.isNotEmpty) {
      path.value = config.filePath;
    } else {
      path.value = config.filePath = pathData.initPath;
    }
  }

  /// 事件 ID
  String _getId() {
    final config = widget.config.value;
    return '${config.name}|${config.group}|${config.value}';
  }

  /// 获取文件路径
  _TPathString _getFilePath() {
    // 资源目录
    String assetsPath = site.currentThemeAssetsPath;
    final config = widget.config.value;
    // 初始图片路径
    String initPath = config.value;
    if (initPath.trim().isEmpty) {
      initPath = '';
    } else {
      initPath = FS.join(assetsPath, initPath);
      if (!FS.fileExistsSync(initPath)) {
        initPath = '';
      }
    }
    // 文件所在的目录
    String dirPath;
    if (initPath.isNotEmpty) {
      dirPath = FS.dirname(initPath);
    } else {
      dirPath = FS.join(assetsPath, site.isThemeCustomPage == true ? 'media' : 'post-images');
    }
    return (initPath: initPath, assetsPath: assetsPath, dirPath: dirPath);
  }

  /// 保存图片
  ///
  /// [path] 图片路径路径
  ///
  /// [current] 当前显示的图片的路径
  Future<void> _saveImage(dynamic params) async {
    var initPath = pathData.initPath;
    // 相同
    if (path.value == initPath) {
      return;
    }
    // 清空
    assert(path.value.isNotEmpty, 'PictureWidget::saveImage : path.value.isNotEmpty is not true');
    bool update = false;
    // 更新路径
    if (widget.randomName || initPath.isEmpty) {
      update = true;
      initPath = FS.join(pathData.dirPath, '${DateTime.now().millisecondsSinceEpoch}${FS.extension(path.value)}');
    }
    // 保存并压缩
    await ImageExt.compress(path.value, initPath);
    // 恢复原有的路径
    path.value = initPath;
    // 更新
    if (update) {
      initPath = FS.join('/', FS.relative(initPath, pathData.assetsPath));
      updateObj(initPath);
    }
  }
}

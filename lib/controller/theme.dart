import 'package:get/get.dart' show GetxController;

class ThemeController extends GetxController {
  ThemeController({
    this.rename = false,
    this.pathDir = '',
  }) : super();

  /// 图片重命名
  final bool rename;

  /// 工作目录的默认路径
  ///
  /// 系统:
  ///
  ///     ''
  ///
  /// 自定义主题:
  ///
  ///     themes/{主题名}/assets
  final String pathDir;

  @override
  void onInit() {
    super.onInit();
  }
}

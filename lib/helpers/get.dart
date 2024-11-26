import 'package:get/get.dart' show Get, GetInterface, GetNavigationExt;
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints, ResponsiveBreakpointsData;

extension GetExt on GetInterface {
  /// 关于当前屏幕的响应性数据
  ResponsiveBreakpointsData get breakpoints => ResponsiveBreakpoints.of(Get.context!);

  /// 判断是否是桌面端
  bool get isDesktop => breakpoints.isDesktop;

  /// 判断是否是移动端
  bool get isMobile => breakpoints.isMobile;
}

import 'dart:ui' show PointerDeviceKind;

import 'package:device_preview_plus/device_preview_plus.dart' show DevicePreview;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetMaterialApp, Inst, Transition;
import 'package:glidea/controller/site.dart';
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/theme.dart';
import 'package:glidea/helpers/windows.dart';
import 'package:glidea/lang/translations.dart';
import 'package:glidea/routes/router.dart';
import 'package:responsive_framework/responsive_framework.dart'
    show Breakpoint, Condition, DESKTOP, PHONE, ResponsiveBreakpoints, ResponsiveScaledBox, ResponsiveValue, TABLET;

import 'controller/site.dart';

// \'package\:(?!.*(?:material|show|glidea))(.*);
// 查找 package 包, 同时排除 material, show, glidea

void main() async {
  await App.initialized();
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    availableLocales: TranslationsService.supportedLocales,
    builder: (context) => const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  /// [App] 初始化
  static Future<void> initialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Log.initialized();
    JsonHelp.initialized();
    WindowsHelp.initialized();
    Get.put<SiteController>(SiteController(), tag: SiteController.tag, permanent: true);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 滚动行为
    final scrollBehavior = const MaterialScrollBehavior().copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
      physics: const BouncingScrollPhysics(),
    );
    return GetMaterialApp(
      title: 'Glidea',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      useInheritedMediaQuery: true,
      scrollBehavior: scrollBehavior,
      locale: DevicePreview.locale(context),
      //Get.deviceLocale,
      translations: TranslationsService(),
      fallbackLocale: TranslationsService.fallbackLocale,
      supportedLocales: TranslationsService.supportedLocales,
      localizationsDelegates: TranslationsService.delegates,
      getPages: AppRouter.routes,
      initialRoute: AppRouter.articles,
      defaultTransition: Transition.fadeIn,
      enableLog: !kReleaseMode,
      builder: Responsive.builder,
    );
  }
}

/// 响应
class Responsive extends StatelessWidget {
  const Responsive({super.key, required this.child});

  /// 子控件
  final Widget child;

  /// 构建
  static Widget builder(BuildContext context, Widget? child) {
    return DevicePreview.appBuilder(context, Responsive(child: child!));
  }

  @override
  Widget build(BuildContext context) {
    final platform = DevicePreview.platform(context);
    final isMobile = platform == TargetPlatform.android || platform == TargetPlatform.iOS;
    return ResponsiveBreakpoints.builder(
      useShortestSide: true,
      child: ResponsiveScale(child: child),
      breakpoints: [
        if (isMobile) const Breakpoint(start: 0, end: windowMinWidth - 1, name: PHONE),
        if (isMobile) const Breakpoint(start: windowMinWidth, end: double.infinity, name: TABLET),
        if (!isMobile) const Breakpoint(start: 0, end: double.infinity, name: DESKTOP),
      ],
    );
  }
}

class ResponsiveScale extends StatelessWidget {
  const ResponsiveScale({super.key, required this.child});

  /// 子控件
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaledBox(
      width: ResponsiveValue<double?>(context, conditionalValues: [
        const Condition.equals(name: PHONE, value: 600),
        const Condition.equals(name: TABLET, value: 900),
        const Condition.equals(name: DESKTOP, value: null),
      ]).value,
      child: child,
    );
  }
}

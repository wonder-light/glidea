import 'dart:io' show Platform;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetMaterialApp, GetNavigationExt, Transition;
import 'package:glidea/helpers/constants.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/helpers/theme.dart';
import 'package:glidea/helpers/windows.dart';
import 'package:glidea/lang/translations.dart';
import 'package:glidea/routes/bindings.dart';
import 'package:glidea/routes/router.dart';
import 'package:responsive_framework/responsive_framework.dart'
    show Breakpoint, Condition, DESKTOP, PHONE, ResponsiveBreakpoints, ResponsiveScaledBox, ResponsiveValue, TABLET;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Log.initialized();
  JsonHelp.initialized();
  await WindowsHelp.initialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
      locale: Get.deviceLocale,
      translations: TranslationsService(),
      fallbackLocale: TranslationsService.fallbackLocale,
      supportedLocales: TranslationsService.supportedLocales,
      localizationsDelegates: TranslationsService.delegates,
      getPages: AppRouter.routes,
      initialRoute: AppRouter.articles,
      defaultTransition: Transition.fadeIn,
      binds: SiteBind.bings,
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

  /// [GetMaterialApp.builder] 构建
  static Widget builder(BuildContext context, Widget? child) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    return ResponsiveBreakpoints.builder(
      useShortestSide: true,
      child: Responsive(child: child!),
      breakpoints: [
        if (isMobile) const Breakpoint(start: 0, end: windowMinWidth - 1, name: PHONE),
        if (isMobile) const Breakpoint(start: windowMinWidth, end: double.infinity, name: TABLET),
        if (!isMobile) const Breakpoint(start: 0, end: double.infinity, name: DESKTOP),
      ],
    );
  }

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

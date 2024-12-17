import 'package:device_preview_plus/device_preview_plus.dart';
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
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Log.initialized();
  JsonHelp.initialized();
  await WindowsHelp.initialized();

  //runApp(const App());
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    availableLocales: TranslationsService.supportedLocales,
    builder: (context) => const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Glidea',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      //Get.deviceLocale,
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
      child: BouncingScrollWrapper(
        dragWithMouse: true,
        child: child,
      ),
    );
  }
}

import 'package:device_preview/device_preview.dart' show DevicePreview;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetMaterialApp, GetNavigationExt, Transition;
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/theme.dart';
import 'package:glidea/lang/translations.dart';
import 'package:glidea/routes/bindings.dart';
import 'package:glidea/routes/router.dart';
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints, Breakpoint, MOBILE, DESKTOP;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JsonHelp.initialized();
  await WindowsHelp.initialized();

  runApp(DevicePreview(
    enabled: !kReleaseMode,
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
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 800, name: MOBILE),
          const Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
        ],
      ),
    );
  }
}

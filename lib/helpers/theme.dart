import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade package to version 8.0.1.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///  theme: AppTheme.light,
///  darkTheme: AppTheme.dark,
///  :
/// );
///
/// more please see [flex_color_scheme ](https://pub.dev/packages/flex_color_scheme);
///
/// To customize the theme, see [Themes Playground](https://rydmike.com/flexcolorscheme/themesplayground-latest/);
sealed class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.hippieBlue,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnLevel: 20,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(12, 16, 12, 12),
      inputDecoratorBackgroundAlpha: 7,
      inputDecoratorBorderSchemeColor: SchemeColor.primary,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 8.0,
      inputDecoratorUnfocusedBorderIsColored: true,
      inputDecoratorBorderWidth: 1.0,
      inputDecoratorFocusedBorderWidth: 2.0,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
      inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
      alignedDropdown: true,
      dialogRadius: 15.0,
      useInputDecoratorThemeInDialogs: true,
      snackBarRadius: 10,
      snackBarBackgroundSchemeColor: SchemeColor.primary,
      drawerSelectedItemSchemeColor: SchemeColor.primary,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailUseIndicator: false,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  ).copyWith(
    iconTheme: const IconThemeData(size: 18)
  );
  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.hippieBlue,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(12, 16, 12, 12),
      inputDecoratorBackgroundAlpha: 40,
      inputDecoratorBorderSchemeColor: SchemeColor.primary,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 8.0,
      inputDecoratorUnfocusedBorderIsColored: true,
      inputDecoratorBorderWidth: 1.0,
      inputDecoratorFocusedBorderWidth: 2.0,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primaryFixed,
      inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
      alignedDropdown: true,
      dialogRadius: 15.0,
      useInputDecoratorThemeInDialogs: true,
      snackBarRadius: 10,
      snackBarBackgroundSchemeColor: SchemeColor.primary,
      drawerSelectedItemSchemeColor: SchemeColor.primary,
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
      navigationRailSelectedIconSchemeColor: SchemeColor.primary,
      navigationRailUseIndicator: false,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  ).copyWith(
      iconTheme: const IconThemeData(size: 18)
  );
}

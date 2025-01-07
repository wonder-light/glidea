import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalCupertinoLocalizations, GlobalMaterialLocalizations, GlobalWidgetsLocalizations;
import 'package:get/get.dart' show Translations;

import 'en_us.dart';
import 'fr_fr.dart';
import 'ja_jp.dart';
import 'ru_ru.dart';
import 'zh_cn.dart';
import 'zh_tw.dart';

class TranslationsService extends Translations {
  /// [Locale] 的默认回调
  static const fallbackLocale = Locale('zh', 'CN');

  /// 语言代码
  static const Map<String, String> languages = {
    'zh_CN': '简体中文',
    'zh_HK': '繁體中文',
    'en_US': 'English',
    'fr_FR': 'Français',
    'ja_JP': '日本語',
    'ru_RU': 'русск',
  };

  /// 用于一组类型为T的本地化资源的工厂，将由本地化小部件加载。
  static List<LocalizationsDelegate> delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// 支持的语言
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('zh', 'HK'),
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ja', 'JP'),
    Locale('ru', 'RU'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        // 简体中文
        'zh_CN': zhCN,
        // 繁体中文
        'zh_HK': zhTW,
        // 英文
        'en_US': en,
        // 法语
        'fr_FR': fr,
        // 日语
        'ja_JP': jp,
        // 俄语
        'ru_RU': ru,
      };
}

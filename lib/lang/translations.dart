import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Translations, GetNavigationExt;

import 'en_us.dart';
import 'fr_fr.dart';
import 'ja_jp.dart';
import 'ru_ru.dart';
import 'zh_cn.dart';
import 'zh_tw.dart';

class TranslationsService extends Translations {
  static Locale? get locale => Get.deviceLocale;

  static const fallbackLocale = Locale('zn', 'CN');

  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN,
        'zh_TW': zhTW,
        'en_US': en,
        'fr_FR': fr,
        'ja_JP': jp,
        'ru_RU': ru,
      };
}

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
        // 简体中文
        'zh_CN': zhCN,
        // 繁体中文
        'zh_TW': zhTW,
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

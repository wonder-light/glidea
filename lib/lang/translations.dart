import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_US.dart';
import 'fr_FR.dart';
import 'ja_JP.dart';
import 'ru_RU.dart';
import 'zh_CN.dart';
import 'zh_TW.dart';

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

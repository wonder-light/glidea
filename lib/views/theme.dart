import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxT, Trans;
import 'package:glidea/components/render/group.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/json.dart';
import 'package:glidea/helpers/log.dart';
import 'package:glidea/models/render.dart';

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

  final inputConfig = (InputConfig()
        ..label = '选择颜色'
        ..name = 'themeName'
        ..note = '选择颜色-note'
        ..hint = '选择颜色-hit'
        ..card = InputCardType.none
        ..value = '#D793D1FF')
      .obs;

  @override
  Widget build(BuildContext context) {
    return GroupWidget(
      isTop: true,
      isScrollable: true,
      groups: const {'basicSetting', 'customConfig'},
      children: [
        Container(
          //color: Colors.accents[Random().nextInt(10)],
          child: Column(
            children: [
              SelectWidget(
                isTop: true,
                config: SelectConfig()
                  ..label = '选择主题'
                  ..name = 'themeName'
                  ..note = '选择主题'
                  ..value = 'notes'
                  ..options = [
                    SelectOption()
                      ..label = 'notes'
                      ..value = 'notes',
                    SelectOption()
                      ..label = 'fly'
                      ..value = 'fly',
                    SelectOption()
                      ..label = 'paper'
                      ..value = 'paper',
                  ],
                onChanged: (String? str) {},
              ),
              TextareaWidget(
                isTop: true,
                config: TextareaConfig()
                  ..label = '选择主题'
                  ..name = 'themeName'
                  ..note = '选择主题-note'
                  ..hint = '选择主题-hit'
                  ..value = 'notes',
                onChanged: (String? str) {},
              ),
              Obx(
                () => InputWidget(
                  isTop: true,
                  config: inputConfig.value,
                  onChanged: (String? str) {
                    inputConfig.value = inputConfig.value.copyWith<InputConfig>({
                      'value': str,
                    })!;
                  },
                ),
              ),
            ],
          ),
        ),
        if (site.themeCustomConfig.isEmpty)
          Container(
            alignment: Alignment.center,
            child: Text('noCustomConfigTip'.tr),
          )
        else
          GroupWidget(
            groups: const {'basicSetting', 'customConfig'},
            children: [
              Container(
                color: Colors.accents[Random().nextInt(10)],
              ),
              Container(
                color: Colors.accents[Random().nextInt(10)],
              ),
            ],
          ),
      ],
    );
  }
}

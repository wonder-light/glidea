import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, Obx, Trans;
import 'package:glidea/components/render/array.dart';
import 'package:glidea/components/render/group.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/picture.dart';
import 'package:glidea/components/render/radio.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/components/render/slider.dart';
import 'package:glidea/components/render/toggle.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
import 'package:glidea/helpers/get.dart';
import 'package:glidea/helpers/json.dart';
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
        ..name = 'input'
        ..note = '选择颜色-note'
        ..hint = '选择颜色-hit'
        ..card = InputCardType.none
        ..value = '#D793D1FF')
      .obs;

  final toggleConfig = (ToggleConfig()
        ..label = '选择颜色'
        ..name = 'toggle'
        ..note = '选择颜色-note'
        ..value = false)
      .obs;

  final radioConfig = (RadioConfig()
        ..label = '选择颜色-Radio'
        ..name = 'radio'
        ..note = 'Radio-note'
        ..value = 'color'
        ..options = [
          SelectOption()
            ..label = '颜色'
            ..value = 'color',
          SelectOption()
            ..label = '配置'
            ..value = 'config',
          SelectOption()
            ..label = '平台'
            ..value = 'panel',
        ])
      .obs;

  final sliderConfig = (SliderConfig()
        ..label = 'Slider 颜色'
        ..name = 'slider'
        ..note = '选择颜色-Slider'
        ..max = 100
        ..value = 40)
      .obs;

  final pictureConfig = (PictureConfig()
        ..label = 'Slider 颜色'
        ..name = 'picture'
        ..note = '选择颜色-Slider'
        ..value = '/post-images/post-feature.jpg')
      .obs;

  final arrayConfig = (ArrayConfig()
        ..label = '数组配置-array'
        ..name = 'array'
        ..note = 'array-note'
        ..value = []
        ..arrayItems = [])
      .obs;

  @override
  void initState() {
    super.initState();
    arrayConfig.value.arrayItems.add(inputConfig.value);
    arrayConfig.value.arrayItems.add(toggleConfig.value);
    arrayConfig.value.arrayItems.add(radioConfig.value);
    arrayConfig.value.arrayItems.add(sliderConfig.value);
    arrayConfig.value.arrayItems.add(arrayConfig.value.copy<ArrayConfig>()!);
  }

  @override
  Widget build(BuildContext context) {
    return GroupWidget(
      isTop: true,
      isScrollable: true,
      groups: const {'basicSetting', 'customConfig'},
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectWidget(
              isTop: true,
              config: (SelectConfig()
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
                    ])
                  .obs,
            ),
            TextareaWidget(
              isTop: true,
              config: (TextareaConfig()
                    ..label = '选择主题'
                    ..name = 'themeName'
                    ..note = '选择主题-note'
                    ..hint = '选择主题-hit'
                    ..value = 'notes')
                  .obs,
            ),
            InputWidget(
              isTop: true,
              config: inputConfig,
            ),
            ToggleWidget(
              isTop: true,
              config: toggleConfig,
            ),
            RadioWidget(
              isTop: true,
              config: radioConfig,
            ),
            SliderWidget(
              isTop: true,
              //configRx: sliderConfig,
              config: sliderConfig,
            ),
            PictureWidget(
              isTop: true,
              config: pictureConfig,
            ),
            ArrayWidget(
              isTop: true,
              config: arrayConfig,
            ),
          ],
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

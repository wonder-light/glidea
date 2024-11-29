import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Obx, RxT, Trans;
import 'package:glidea/components/render/group.dart';
import 'package:glidea/components/render/input.dart';
import 'package:glidea/components/render/picture.dart';
import 'package:glidea/components/render/radio.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/components/render/slider.dart';
import 'package:glidea/components/render/toggle.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/enum/enums.dart';
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
        ..name = 'themeName'
        ..note = '选择颜色-note'
        ..hint = '选择颜色-hit'
        ..card = InputCardType.none
        ..value = '#D793D1FF')
      .obs;

  final toggleConfig = (ToggleConfig()
        ..label = '选择颜色'
        ..name = 'themeName'
        ..note = '选择颜色-note'
        ..value = false)
      .obs;

  final radioConfig = (RadioConfig()
        ..label = '选择颜色-Radio'
        ..name = 'themeName'
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
    ..name = 'themeName'
    ..note = '选择颜色-Slider'
    ..max = 100
    ..value = 40)
      .obs;

  final pictureConfig = (PictureConfig()
    ..label = 'Slider 颜色'
    ..name = 'themeName'
    ..note = '选择颜色-Slider'
    ..value = '/post-images/post-feature.jpg')
      .obs;

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
            Obx(
                  () => ToggleWidget(
                isTop: true,
                config: toggleConfig.value,
                onChanged: (bool str) {
                  toggleConfig.value = toggleConfig.value.copyWith<ToggleConfig>({
                    'value': str,
                  })!;
                },
              ),
            ),
            Obx(
                  () => RadioWidget(
                isTop: true,
                config: radioConfig.value,
                onChanged: (String? str) {
                  radioConfig.value = radioConfig.value.copyWith<RadioConfig>({
                    'value': str,
                  })!;
                },
              ),
            ),
            Obx(
                  () => SliderWidget(
                isTop: true,
                config: sliderConfig.value,
                onChanged: (double value) {
                  sliderConfig.value = sliderConfig.value.copyWith<SliderConfig>({
                    'value': value,
                  })!;
                },
              ),
            ),
            Obx(
                  () => PictureWidget(
                isTop: true,
                config: pictureConfig.value,
                onChanged: (dynamic value) {
                  /*pictureConfig.value = pictureConfig.value.copyWith<SliderConfig>({
                    'value': value,
                  })!;*/
                },
              ),
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

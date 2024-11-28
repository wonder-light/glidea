import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt, Inst, Trans;
import 'package:glidea/components/render/group.dart';
import 'package:glidea/components/render/select.dart';
import 'package:glidea/controller/site.dart';
import 'package:glidea/models/render.dart';

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {
  /// 站点控制器
  final site = Get.find<SiteController>(tag: SiteController.tag);

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
                select: SelectConfig()
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

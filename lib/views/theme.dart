import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;
import 'package:glidea/components/render/group.dart';
import 'package:glidea/models/render.dart';

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {
  @override
  Widget build(BuildContext context) {
    return GroupWidget(
      isTop: false,
      configs: [
        InputConfig()..group = '布局',
        RadioConfig()..group = '布局',
        ToggleConfig()..group = '布局',
        PictureConfig()..group = '颜色',
        SliderConfig()..group = '颜色',
      ],
    );
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: const Text('主题'),
    );
  }
}

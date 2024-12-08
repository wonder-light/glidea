import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: const Text('设置'),
    );
  }
}

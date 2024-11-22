import 'package:flutter/material.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {

  @override
  Widget build(BuildContext context) {
    return const Text('设置');
  }
}

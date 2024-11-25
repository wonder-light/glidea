import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;

class RemoteWidget extends StatefulWidget {
  const RemoteWidget({super.key});

  @override
  State<RemoteWidget> createState() => _RemoteWidgetState();
}

class _RemoteWidgetState extends State<RemoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: const Text('远程'),
    );
  }
}

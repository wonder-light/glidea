import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, GetNavigationExt;

class RemoteView extends StatefulWidget {
  const RemoteView({super.key});

  @override
  State<RemoteView> createState() => _RemoteViewState();
}

class _RemoteViewState extends State<RemoteView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      child: const Text('远程'),
    );
  }
}

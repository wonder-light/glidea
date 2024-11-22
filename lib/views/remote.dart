import 'package:flutter/material.dart';

class RemoteWidget extends StatefulWidget {
  const RemoteWidget({super.key});

  @override
  State<RemoteWidget> createState() => _RemoteWidgetState();
}

class _RemoteWidgetState extends State<RemoteWidget> {

  @override
  Widget build(BuildContext context) {
    return const Text('远程');
  }
}

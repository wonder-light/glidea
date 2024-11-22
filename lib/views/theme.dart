import 'package:flutter/material.dart';

class ThemeWidget extends StatefulWidget {
  const ThemeWidget({super.key});

  @override
  State<ThemeWidget> createState() => _ThemeWidgetState();
}

class _ThemeWidgetState extends State<ThemeWidget> {

  @override
  Widget build(BuildContext context) {
    return const Text('主题');
  }
}

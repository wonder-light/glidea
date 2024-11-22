import 'package:flutter/material.dart';

class ArticlesWidget extends StatefulWidget {
  const ArticlesWidget({super.key});

  @override
  State<ArticlesWidget> createState() => _ArticlesWidgetState();
}

class _ArticlesWidgetState extends State<ArticlesWidget> {

  @override
  Widget build(BuildContext context) {
    return const Text('文章');
  }
}

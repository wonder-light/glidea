import 'package:flutter/material.dart';
import 'package:glidea/models/tag.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart' show PhosphorIconsRegular;

class TagEditorWidget extends StatelessWidget {
  const TagEditorWidget({super.key, required this.tag});

  /// 标签
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Text('tag'),
            Icon(PhosphorIconsRegular.plus)
          ],
        )
      ],
    );
  }
}

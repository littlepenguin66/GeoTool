import 'package:flutter/material.dart';
import '../models/tool.dart';

class ToolDetailsItem extends StatelessWidget {
  final ToolFeature feature;
  final VoidCallback onTap;

  const ToolDetailsItem({super.key, required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.build),
      title: Text(feature.name),
      subtitle: Text(feature.description),
      onTap: onTap,
    );
  }
}

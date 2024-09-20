import 'package:flutter/material.dart';

class Tool {
  final String name;
  final IconData icon;
  final List<ToolFeature> features;

  Tool({
    required this.name,
    required this.icon,
    this.features = const [],
  });
}

class ToolFeature {
  final String name;
  final String description;

  ToolFeature({
    required this.name,
    required this.description,
  });
}

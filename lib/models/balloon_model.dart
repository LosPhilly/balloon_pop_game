import 'package:flutter/material.dart';

class Balloon {
  final String imagePath;
  final double size;
  late final Offset position;
  final int points;
  final double timeChange; // New field to handle time addition/subtraction
  final String? iconPath; // Path to the icon to display on the balloon

  Balloon({
    required this.imagePath,
    required this.size,
    required this.position,
    required this.points,
    this.timeChange = 0.0, // Default to no time change
    this.iconPath,
  });
}

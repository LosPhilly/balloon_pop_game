import 'package:flutter/material.dart';

class Balloon {
  final String imagePath;
  final double size;
  final Offset position;
  final int points;

  Balloon({
    required this.imagePath,
    required this.size,
    required this.position,
    required this.points,
  });
}

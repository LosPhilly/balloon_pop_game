import 'package:flutter/material.dart';
import '../models/balloon_model.dart';

class BalloonWidget extends StatelessWidget {
  final Balloon balloon;
  final VoidCallback onPop;

  const BalloonWidget({Key? key, required this.balloon, required this.onPop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: balloon.position.dx,
      top: balloon.position.dy,
      child: GestureDetector(
        onTap: onPop,
        child: Image.asset(
          balloon.imagePath,
          width: balloon.size,
          height: balloon.size,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/balloon_model.dart';

class BalloonWidget extends StatelessWidget {
  final Balloon balloon;
  final VoidCallback onPop;

  BalloonWidget({required this.balloon, required this.onPop});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: balloon.position.dx,
      top: balloon.position.dy,
      child: GestureDetector(
        onTap: onPop,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              balloon.imagePath,
              width: balloon.size,
              height: balloon.size,
            ),
            if (balloon.iconPath != null)
              Positioned(
                bottom: 10, // Adjusts the position of the icon
                child: Image.asset(
                  balloon.iconPath!,
                  width: balloon.size /
                      3, // Adjusted icon size relative to balloon size
                  height: balloon.size /
                      3, // Adjusted icon size relative to balloon size
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/home_screen_balloon_model.dart';

class HomeScreenBalloonWidget extends StatelessWidget {
  final HomeScreenBalloon balloon;

  HomeScreenBalloonWidget({required this.balloon});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      balloon.imagePath,
      width: balloon.size,
      height: balloon.size,
    );
  }
}

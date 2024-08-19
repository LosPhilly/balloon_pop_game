import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../models/home_screen_balloon_model.dart';
import '../widgets/home_screen_balloon_widget.dart'; // Import the new widget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<HomeScreenBalloon> balloons = [];
  Timer? balloonTimer;

  @override
  void initState() {
    super.initState();
    balloonTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _generateBalloon();
    });
  }

  @override
  void dispose() {
    balloonTimer?.cancel();
    super.dispose();
  }

  void _generateBalloon() {
    final random = Random();
    final size =
        random.nextDouble() * 50 + 50; // Random size between 50 and 100
    final xPosition = random.nextDouble() * MediaQuery.of(context).size.width;

    final balloonImages = [
      'assets/images/balloons/balloon_red.png',
      'assets/images/balloons/balloon_blue.png',
      'assets/images/balloons/balloon_green.png',
      // Add more balloon image paths here
    ];

    final balloonImage = balloonImages[random.nextInt(balloonImages.length)];

    final balloon = HomeScreenBalloon(
      imagePath: balloonImage,
      size: size,
      position: Offset(xPosition, MediaQuery.of(context).size.height),
    );

    setState(() {
      balloons.add(balloon);
    });

    // Move the balloon up the screen
    _animateBalloon(balloon);
  }

  void _animateBalloon(HomeScreenBalloon balloon) {
    final duration = Duration(seconds: 10);
    final endPosition = -balloon.size;

    Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        final newY = balloon.position.dy -
            (MediaQuery.of(context).size.height /
                (duration.inMilliseconds / 16));
        balloon.position = Offset(balloon.position.dx, newY);

        if (balloon.position.dy <= endPosition) {
          balloons.remove(balloon);
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    bool isNightMode = themeProvider.isNightMode;
    bool isGuest = authProvider.isGuest;

    // Choose a background image based on the theme
    final backgroundImage = isNightMode
        ? 'assets/images/dark/sky_dark_1.png' // Dark theme background
        : 'assets/images/light/sky_1.png'; // Light theme background

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // Floating balloons
          ...balloons.map((balloon) {
            return Positioned(
              left: balloon.position.dx,
              top: balloon.position.dy,
              child: HomeScreenBalloonWidget(
                balloon: balloon,
              ),
            );
          }).toList(),
          // Buttons
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/game');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Start Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS', // Playful font
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/leaderboard');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.leaderboard, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Leaderboard',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS', // Playful font
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGuest
                          ? Colors.grey
                          : Colors.orangeAccent, // Disable for guest
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: isGuest
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/achievements');
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            color: isGuest
                                ? Colors.white54
                                : Colors.white), // Disabled color
                        SizedBox(width: 10),
                        Text(
                          'Achievements',
                          style: TextStyle(
                            color: isGuest ? Colors.white54 : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS', // Playful font
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGuest
                          ? Colors.grey
                          : Colors.blueAccent, // Disable for guest
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: isGuest
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/profile');
                          }, // Navigate to Profile
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            color: isGuest
                                ? Colors.white54
                                : Colors.white), // Disabled color
                        SizedBox(width: 10),
                        Text(
                          'My Stats',
                          style: TextStyle(
                            color: isGuest ? Colors.white54 : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS', // Playful font
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS', // Playful font
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

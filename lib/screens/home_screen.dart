import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../models/home_screen_balloon_model.dart';
import '../widgets/home_screen_balloon_widget.dart';

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
      'assets/images/balloons/balloon_yellow.png',
      'assets/images/balloons/balloon_purple.png',
      'assets/images/balloons/balloon_orange.png',
      'assets/images/balloons/balloon_gold.png',
      'assets/images/balloons/balloon_silver.png',
      'assets/images/balloons/balloon_star.png',
      'assets/images/balloons/balloon_trick.png',
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

  void _showSignInDialog(bool isGuest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        bool isNightMode = themeProvider.isNightMode;

        return AlertDialog(
          backgroundColor: isNightMode ? Colors.black87 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isNightMode ? Colors.white : Colors.black,
              fontFamily: 'Comic Sans MS',
            ),
          ),
          content: Text(
            'You must be signed in to access this feature.',
            style: TextStyle(
              fontSize: 18,
              color: isNightMode ? Colors.white70 : Colors.black87,
              fontFamily: 'Comic Sans MS',
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    isNightMode ? Colors.grey[800] : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  color: isNightMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'Comic Sans MS',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    isNightMode ? Colors.blueAccent : Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    bool isNightMode = themeProvider.isNightMode;
    bool isGuest = authProvider.isGuest;

    // Choose a background image based on the theme
    final backgroundImage = isNightMode
        ? 'assets/images/dark/sky_dark_1.png'
        : 'assets/images/light/sky_1.png';

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
          // Logo and buttons
          Positioned.fill(
            child: SingleChildScrollView(
              // Added SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add the logo at the top
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0), // Added padding
                    child: Image.asset(
                      'assets/images/kids_game.png', // Your logo image
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 50),
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
                            fontFamily: 'Comic Sans MS',
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
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 5,
                    ),
                    onPressed: isGuest
                        ? () => _showSignInDialog(isGuest)
                        : () {
                            Navigator.pushNamed(context, '/achievements');
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Achievements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
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
                    onPressed: isGuest
                        ? () => _showSignInDialog(isGuest)
                        : () {
                            Navigator.pushNamed(context, '/profile');
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'My Stats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Sans MS',
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
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 20), // Add a bottom spacing to prevent overflow
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

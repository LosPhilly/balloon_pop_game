import 'package:balloon_pop_game/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:math';
import '../models/home_screen_balloon_model.dart';
import '../widgets/home_screen_balloon_widget.dart';
import '../providers/theme_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      'assets/images/balloons/balloon_trick.png', // Trick balloon that ends the game
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
      if (!mounted) {
        timer.cancel();
        return;
      }

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
    bool isNightMode = themeProvider.isNightMode;

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
          // Content
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/kids_game.png', // Your logo image
                      height: 150,
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context,
                            '/user_signup'); // Navigate to User Sign-Up page
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/login'); // Navigate to Login page
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        _handleGoogleSignIn(context); // Handle Google sign-in
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        authProvider.signInAsGuest();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Text(
                        'Play as Guest',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Google sign-in failed. Please try again.'),
      ));
    }
  }
}

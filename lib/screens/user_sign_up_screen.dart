import 'package:balloon_pop/providers/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/home_screen_balloon_model.dart';
import '../widgets/home_screen_balloon_widget.dart';
import 'dart:async';
import 'dart:math';

class UserSignUpScreen extends StatefulWidget {
  @override
  _UserSignUpScreenState createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String email = '';
  String password = '';

  bool isLoading = false;
  String errorMessage = '';

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

  void signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update the display name in Firebase Auth
        await userCredential.user?.updateDisplayName(username);

        // Initialize achievements
        List<Map<String, dynamic>> initialAchievements = [];

        // Store user profile information in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'username': username,
          'email': email,
          'score': 0, // Initial score
          'level': 1, // Initial level
          'balloonsPopped': 0, // Total balloons popped
          'balloonStats': {
            'red': 0,
            'blue': 0,
            'green': 0,
            'yellow': 0,
            'purple': 0,
            'orange': 0,
            'gold': 0,
            'silver': 0,
            'star': 0,
            'trick': 0,
          }, // Stats for each balloon type
          'achievements': initialAchievements, // Initial achievements list
        });

        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'Something went wrong';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isNightMode
                  ? 'assets/images/dark/sky_dark_1.png'
                  : 'assets/images/light/sky_1.png',
              fit: BoxFit.cover,
            ),
          ),
          ...balloons.map((balloon) {
            return Positioned(
              left: balloon.position.dx,
              top: balloon.position.dy,
              child: HomeScreenBalloonWidget(
                balloon: balloon,
              ),
            );
          }).toList(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        labelText: 'Username',
                        icon: Icons.person,
                        onChanged: (value) {
                          setState(() {
                            username = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a username'
                            : null,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        labelText: 'Email',
                        icon: Icons.email,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        labelText: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        validator: (value) => value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      SizedBox(height: 20),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: 20),
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: signUp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 40),
                                backgroundColor:
                                    Colors.greenAccent, // Matching game theme
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

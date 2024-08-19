import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class GameOverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Capture the arguments passed to this screen
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    // Debugging: Print the received arguments to the console
    print('Received arguments: $args');

    // Default to 0 if arguments are null or not an int
    int finalScore = 0;
    if (args != null && args is int) {
      finalScore = args;
    } else {
      print('Error: Received arguments are either null or not an int.');
    }

    // Debugging: Print the final score to the console
    print('Final Score: $finalScore');

    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Game Over',
          style: TextStyle(
            color: isNightMode ? Colors.white : Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Comic Sans MS', // Playful font
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Final Score: $finalScore',
              style: TextStyle(
                color: isNightMode ? Colors.redAccent : Colors.blueAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS', // Playful font
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/game'); // Restart the game
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Play Again',
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
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/leaderboard');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Leaderboard',
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
    );
  }
}

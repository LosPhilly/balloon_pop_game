import 'package:balloon_pop_game/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class GameOverPopup extends StatefulWidget {
  final int finalScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onViewLeaderboard;
  final VoidCallback onBackToMenu;

  GameOverPopup({
    required this.finalScore,
    required this.onPlayAgain,
    required this.onViewLeaderboard,
    required this.onBackToMenu,
  });

  @override
  _GameOverPopupState createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return AlertDialog(
      backgroundColor: isNightMode ? Colors.black : Colors.white,
      title: Text(
        'Game Over',
        style: TextStyle(
          color: isNightMode ? Colors.white : Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Final Score: ${widget.finalScore}',
            style: TextStyle(
              color: isNightMode ? Colors.redAccent : Colors.blueAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comic Sans MS',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Enter your name',
              border: const OutlineInputBorder(),
              labelStyle: TextStyle(
                color: isNightMode ? Colors.white : Colors.black,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isNightMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            style: TextStyle(
              color: isNightMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 5,
            ),
            onPressed: () async {
              final playerName = nameController.text.trim();
              if (playerName.isNotEmpty) {
                await submitScore(playerName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Score has been added successfully!'),
                    ),
                  );
                  // Keep the dialog open and don't restart the game
                }
              } else {
                // Show a message to enter a name
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter your name to submit the score.'),
                    ),
                  );
                }
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, color: Colors.black),
                SizedBox(width: 10),
                Text(
                  'Submit Score',
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
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 5,
            ),
            onPressed: widget.onViewLeaderboard,
            child: const Row(
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
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 5,
            ),
            onPressed: widget.onPlayAgain,
            child: const Row(
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
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 5,
            ),
            onPressed: widget.onBackToMenu,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Back to Menu',
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
        ],
      ),
    );
  }

  Future<void> submitScore(String playerName) async {
    final leaderboardService = LeaderboardService();
    try {
      await leaderboardService.submitScore(playerName, widget.finalScore);
      // Safely show a SnackBar only if the widget is still active
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Score submitted successfully'),
        ));
      }
    } catch (e) {
      if (mounted) {
        // Handle errors during submission and show a SnackBar if the widget is still active
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to submit score. Please try again.'),
        ));
      }
    }
  }
}

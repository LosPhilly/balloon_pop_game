import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';

class SubmitScoreWidget extends StatelessWidget {
  final int finalScore;
  final TextEditingController nameController = TextEditingController();

  SubmitScoreWidget({required this.finalScore});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Submit Your Score',
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Comic Sans MS',
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Final Score: $finalScore',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comic Sans MS',
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            onPressed: () async {
              final playerName = nameController.text.trim();
              if (playerName.isNotEmpty) {
                await submitScore(context, playerName);
                Navigator.pop(context); // Close the dialog after submission
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please enter your name to submit the score.'),
                ));
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, color: Colors.black),
                SizedBox(width: 10),
                Text(
                  'Submit Score',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
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

  Future<void> submitScore(BuildContext context, String playerName) async {
    final leaderboardService = LeaderboardService();
    try {
      await leaderboardService.submitScore(playerName, finalScore);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Score submitted successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit score: $e'),
      ));
    }
  }
}

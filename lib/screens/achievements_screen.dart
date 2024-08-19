import 'package:balloon_pop_game/widgets/achievement_widget.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'First Pop!',
      'description': 'Pop your first balloon',
      'isUnlocked': true
    },
    {
      'title': 'Pop Master',
      'description': 'Pop 100 balloons',
      'isUnlocked': false
    },
    {
      'title': 'Speed Demon',
      'description': 'Reach level 5 in under 2 minutes',
      'isUnlocked': false
    },
    {
      'title': 'Time Keeper',
      'description': 'Keep the timer above 20 seconds for 3 levels',
      'isUnlocked': false
    },
    {
      'title': 'Pop Pro',
      'description': 'Pop 500 balloons',
      'isUnlocked': false
    },
    {
      'title': 'Balloon Buster',
      'description': 'Pop 1000 balloons',
      'isUnlocked': false
    },
    {
      'title': 'Level Crusher',
      'description': 'Reach level 10',
      'isUnlocked': false
    },
    {
      'title': 'Survivor',
      'description': 'Play 5 games without losing',
      'isUnlocked': false
    },
    {
      'title': 'Pop Legend',
      'description': 'Score over 1000 points in a single game',
      'isUnlocked': false
    },
    // Add more achievements here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        elevation: 0,
        title: Text(
          'Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Comic Sans MS',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return AchievementWidget(
              title: achievements[index]['title'],
              description: achievements[index]['description'],
              isUnlocked: achievements[index]['isUnlocked'],
            );
          },
        ),
      ),
    );
  }
}

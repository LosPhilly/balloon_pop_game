import 'package:flutter/material.dart';
import '../models/balloon_model.dart';
import '../widgets/balloon_widget.dart';
import '../services/achievements_service.dart';
import '../services/leaderboard_service.dart';
import '../services/game_logic_service.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLogicService gameLogicService = GameLogicService();
  final leaderboardService = LeaderboardService();
  final achievementsService = AchievementsService();

  @override
  void initState() {
    super.initState();
    gameLogicService.startGame(updateState, context);
  }

  @override
  void dispose() {
    // Clean up resources
    gameLogicService.gameTimer?.cancel();
    gameLogicService.balloonGeneratorTimer?.cancel();
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  void popBalloon(Balloon balloon) {
    gameLogicService.popBalloon(balloon, updateState);

    // Additional logic if needed (e.g., checking achievements, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Set a playful background color
      body: Stack(
        children: [
          // Display balloons
          ...gameLogicService.balloons.map((balloon) {
            return BalloonWidget(
              balloon: balloon,
              onPop: () {
                popBalloon(balloon);
                if (gameLogicService.balloons.isEmpty) {
                  gameLogicService
                      .endGame(); // Check game over condition when a balloon is popped
                }
              },
            );
          }).toList(),

          // Floating stats container at the bottom
          Positioned(
            bottom: 20, // Positioning at the bottom
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time left
                _buildFloatingStat(
                  icon: Icons.timer,
                  label: 'Time Left',
                  value: '${gameLogicService.timeLeft.toStringAsFixed(1)}s',
                  color: Colors.redAccent,
                ),

                // Score
                _buildFloatingStat(
                  icon: Icons.star,
                  label: 'Score',
                  value: '${gameLogicService.score}',
                  color: Colors.yellowAccent,
                ),

                // Level
                _buildFloatingStat(
                  icon: Icons.emoji_events,
                  label: 'Level',
                  value: '${gameLogicService.level}',
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/balloon_model.dart';
import '../widgets/game_over_popup.dart';
import '../providers/auth_provider.dart';
import '../services/achievements_service.dart';

class GameLogicService {
  int score = 0;
  int level = 1;
  int balloonsPopped = 0; // Track the number of balloons popped per level
  int balloonsRequired = 5; // Balloons required to level up
  int starBalloonsCollected = 0; // Track the number of star balloons collected
  double timeLeft = 10.0; // Start with 10 seconds for more urgency
  List<Balloon> balloons = [];
  Timer? gameTimer;
  Timer? balloonGeneratorTimer;
  BuildContext? context; // To store the context passed from GameScreen

  final AchievementsService achievementsService =
      AchievementsService(); // Instantiate AchievementsService

  Color timeLeftColor = Colors.red; // Default time left color

  void startGame(Function updateState, BuildContext context) {
    this.context = context;
    preloadImages(); // Preload images

    // Generate balloons at intervals
    balloonGeneratorTimer =
        Timer.periodic(Duration(milliseconds: 1000), (timer) {
      generateBalloon(updateState);
    });

    // Update the game state and timer
    gameTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      updateGameState(updateState);
    });
  }

  void preloadImages() {
    // Preload balloon images to optimize loading times
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

    // This could be used to preload if needed
  }

  void generateBalloon(Function updateState) {
    final random = Random();

    // Generate more balloons at higher levels
    int numberOfBalloons =
        1 + (level ~/ 5); // Increase the number of balloons every 5 levels

    for (int i = 0; i < numberOfBalloons; i++) {
      final size =
          random.nextDouble() * 100 + 120; // Increased size: 120 to 220
      final xPosition = random.nextDouble() *
          800; // Replace with MediaQuery for dynamic width

      final balloonImage = _getBalloonImage();

      final balloon = Balloon(
        imagePath: balloonImage,
        size: size,
        position: Offset(xPosition,
            600 - size), // Replace with MediaQuery for dynamic height
        points: size.toInt(),
        timeChange: _getTimeChangeForBalloon(balloonImage),
        iconPath: _getTimeIconForBalloon(balloonImage),
      );

      balloons.add(balloon);
    }

    updateState();
  }

  String _getBalloonImage() {
    final random = Random();
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

    return balloonImages[random.nextInt(balloonImages.length)];
  }

  double _getTimeChangeForBalloon(String balloonImage) {
    if (balloonImage == 'assets/images/balloons/balloon_trick.png') {
      return 0.0;
    }

    // Assign specific time change values based on the icon path
    if (balloonImage.contains('subtract_time')) {
      return -2.0;
    } else if (balloonImage.contains('add_time')) {
      return 2.0;
    }

    return 0.0;
  }

  String? _getTimeIconForBalloon(String balloonImage) {
    if (balloonImage == 'assets/images/balloons/balloon_trick.png') {
      return null;
    }

    // Explicitly assign the correct icon based on time change
    final random = Random();
    if (random.nextBool()) {
      return 'assets/images/icons/subtract_time.png';
    } else {
      return 'assets/images/icons/add_time.png';
    }
  }

  void updateGameState(Function updateState) {
    timeLeft -= 0.1;

    if (timeLeft <= 0) {
      timeLeft = 0;
      endGame();
      return;
    }

    if (balloonsPopped >= balloonsRequired) {
      levelUp();
    }

    updateBalloonPositions();
    updateState();
  }

  void updateBalloonPositions() {
    balloons = balloons.map((balloon) {
      // Increase the speed as levels progress
      final newY = balloon.position.dy - (5 + level * 0.5);
      return Balloon(
        imagePath: balloon.imagePath,
        size: balloon.size,
        position: Offset(balloon.position.dx, newY),
        points: balloon.points,
        timeChange: balloon.timeChange,
        iconPath: balloon.iconPath,
      );
    }).toList();

    // Remove balloons that reached the top
    balloons.removeWhere((balloon) => balloon.position.dy < 0);
  }

  void popBalloon(Balloon balloon, Function updateState) {
    // If the balloon is the trick balloon, end the game immediately.
    if (balloon.imagePath == 'assets/images/balloons/balloon_trick.png') {
      endGame();
      return;
    }

    score += balloon.points;
    balloonsPopped++;

    // Track the number of star balloons collected.
    if (balloon.imagePath == 'assets/images/balloons/balloon_star.png') {
      starBalloonsCollected++;
    }

    // Only modify time if the timeChange is non-zero.
    if (balloon.timeChange != 0.0) {
      timeLeft += balloon.timeChange;
      _showTimeChangeFeedback(balloon.timeChange > 0.0, updateState);
    }

    // Remove the balloon and update the state.
    balloons.remove(balloon);

    // Update user stats if logged in.
    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    if (!authProvider.isGuest) {
      _updateUserStats(balloon, authProvider.user?.uid);
    }

    updateState();

    // Check for all relevant achievements.
    _checkAchievements();
  }

  void levelUp() {
    level++;
    balloonsPopped = 0; // Reset the count for the new level
    balloonsRequired +=
        3; // Increase the number of balloons needed for the next level

    // Adjust the balloon generation speed to increase difficulty
    balloonGeneratorTimer?.cancel();
    int generationInterval =
        max(1000 - level * 100, 200); // Speed up the game as levels increase
    balloonGeneratorTimer = Timer.periodic(
      Duration(milliseconds: generationInterval),
      (timer) {
        generateBalloon(() {});
      },
    );

    _showLevelUpFeedback();

    // Check for level-related achievements
    achievementsService.checkForAchievements(score, starBalloonsCollected);
  }

  void _showLevelUpFeedback() {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text('Level Up! You are now on level $level.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTimeChangeFeedback(bool isPositive, Function updateState) {
    // Temporarily change the color of the time left indicator to green or red
    timeLeftColor = isPositive ? Colors.green : Colors.red;

    updateState();

    Timer(Duration(seconds: 1), () {
      timeLeftColor = Colors.red;
      updateState();
    });
  }

  void _checkAchievements() {
    achievementsService.checkForAchievements(score, starBalloonsCollected);

    // Check specific achievements
    if (balloonsPopped == 1) {
      achievementsService.unlockAchievement(
        'First Pop!',
        'Pop your first balloon',
      );
    }

    if (balloonsPopped >= 100) {
      achievementsService.unlockAchievement(
        'Pop Master',
        'Pop 100 balloons',
      );
    }

    if (balloonsPopped >= 500) {
      achievementsService.unlockAchievement(
        'Pop Pro',
        'Pop 500 balloons',
      );
    }

    if (balloonsPopped >= 1000) {
      achievementsService.unlockAchievement(
        'Balloon Buster',
        'Pop 1000 balloons',
      );
    }

    if (score >= 1000) {
      achievementsService.unlockAchievement(
        'Pop Legend',
        'Score over 1000 points in a single game',
      );
    }

    // Add more specific checks here as needed
  }

  Future<void> _updateUserStats(Balloon balloon, String? userId) async {
    if (userId == null) return;

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final userData = await userDocRef.get();
    if (!userData.exists) return;

    final currentStats = userData.data() as Map<String, dynamic>;

    // Ensure 'balloonStats' and the specific balloon type key exist
    Map<String, dynamic> balloonStats = currentStats['balloonStats'] ?? {};
    final balloonType = balloon.imagePath.split('/').last.split('.').first;

    // Initialize the balloon type count if it doesn't exist
    balloonStats[balloonType] = (balloonStats[balloonType] ?? 0) + 1;

    // Increment the total balloons popped
    currentStats['balloonsPopped'] = (currentStats['balloonsPopped'] ?? 0) + 1;

    // Update the score
    currentStats['score'] = (currentStats['score'] ?? 0) + score;

    // Check for leveling up based on star balloons collected
    if (starBalloonsCollected >= level * 10) {
      level++;
      currentStats['level'] = level;
      _showLevelUpFeedback();
    }

    // Save the updated stats back to Firestore
    await userDocRef.update({
      'balloonStats': balloonStats,
      'balloonsPopped': currentStats['balloonsPopped'],
      'score': currentStats['score'],
      'level': currentStats['level'],
    });
  }

  void showGameOverPopup() {
    if (context != null && ModalRoute.of(context!)!.isCurrent) {
      showDialog(
        context: context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GameOverPopup(
            finalScore: score,
            onPlayAgain: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacementNamed(context, '/game');
            },
            onViewLeaderboard: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacementNamed(context, '/leaderboard');
            },
            onBackToMenu: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacementNamed(context, '/menu');
            },
          );
        },
      );
    } else {
      print('Error: Invalid or disposed context.');
    }
  }

  void endGame() {
    gameTimer?.cancel();
    balloonGeneratorTimer?.cancel();
    showGameOverPopup();

    // Check for game-ending achievements
    _checkAchievements();
  }
}

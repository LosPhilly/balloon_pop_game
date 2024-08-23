import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  double timeLeft = 20.0; // Start with 20 seconds for easier gameplay
  List<Balloon> balloons = [];
  Timer? gameTimer;
  Timer? balloonGeneratorTimer;
  BuildContext? context; // To store the context passed from GameScreen

  final AchievementsService achievementsService =
      AchievementsService(); // Instantiate AchievementsService

  Color timeLeftColor = Colors.red; // Default time left color

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-1135480968301432~9313890103', // Replace with your actual Ad Unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load an interstitial ad: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd(Function onAdClosed) {
    if (_isInterstitialAdReady) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          onAdClosed(); // Continue with game over popup after ad
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('Failed to show interstitial ad: $error');
          ad.dispose();
          onAdClosed(); // Continue with game over popup even if ad fails
        },
      );

      _interstitialAd?.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    } else {
      onAdClosed(); // If the ad isn't ready, just show the game over popup
    }
  }

  void startGame(Function updateState, BuildContext context) {
    this.context = context;
    preloadImages(); // Preload images

    // Generate balloons at intervals
    balloonGeneratorTimer =
        Timer.periodic(Duration(milliseconds: 1200), (timer) {
      // Increased interval for easier gameplay
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

    // Increase the number of balloons generated as the game progresses
    int numberOfBalloons = 2 + (level ~/ 2); // Increase balloons every 2 levels

    for (int i = 0; i < numberOfBalloons; i++) {
      final size =
          random.nextDouble() * 100 + 140; // Larger balloons (140 to 240)
      final xPosition =
          random.nextDouble() * MediaQuery.of(context!).size.width;

      // Adjust the probability of "add time" balloons as levels increase
      double addTimeProbability =
          max(0.3 - (level * 0.04), 0.01); // Reduces to a minimum of 5%

      final bool isAddTimeBalloon = random.nextDouble() < addTimeProbability;

      final balloonImage = isAddTimeBalloon
          ? 'assets/images/balloons/balloon_star.png' // Use specific balloon image
          : _getBalloonImage();

      final balloon = Balloon(
        imagePath: balloonImage,
        size: size,
        position: Offset(xPosition, MediaQuery.of(context!).size.height - size),
        points: size.toInt(),
        timeChange: isAddTimeBalloon
            ? 3.0
            : 0.0, // Add time only for "add time" balloons
        iconPath: isAddTimeBalloon
            ? 'assets/images/icons/add_time.png'
            : null, // Show icon for "add time" balloons
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
    // If it's an "add time" balloon, return the time addition
    if (balloonImage.contains('add_time')) {
      return 3.0; // Add 3 seconds
    }

    return 0.0; // No time change for other balloons
  }

  String? _getTimeIconForBalloon(String balloonImage) {
    // Only show the add time icon for balloons that add time
    if (balloonImage.contains('add_time')) {
      return 'assets/images/icons/add_time.png'; // Ensure this path is correct
    }

    return null; // No icon for other balloons
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
      // Decrease the speed to make the game easier
      final newY = balloon.position.dy - (3 + level * 0.3); // Slower speed
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
    // No more ending the game when clicking on certain balloons
    score += balloon.points;
    balloonsPopped++;

    // Track the number of star balloons collected.
    if (balloon.imagePath == 'assets/images/balloons/balloon_star.png') {
      starBalloonsCollected++;
    }

    // Only modify time if the timeChange is positive
    if (balloon.timeChange > 0.0) {
      timeLeft += balloon.timeChange;
      _showTimeChangeFeedback(true, updateState);
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
        5; // Increase the number of balloons required to level up by 5 each time

    // Adjust the balloon generation speed to a slower increase in difficulty
    balloonGeneratorTimer?.cancel();
    int generationInterval =
        max(1200 - level * 50, 600); // Slower difficulty increase
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
    // Temporarily change the color of the time left indicator to green
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

    // Load the interstitial ad
    _loadInterstitialAd();

    // Show the interstitial ad, and after it closes, show the game over popup
    _showInterstitialAd(() {
      showGameOverPopup();
    });

    // Check for game-ending achievements
    _checkAchievements();
  }
}

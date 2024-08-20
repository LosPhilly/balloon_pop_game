import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/balloon_model.dart';
import '../widgets/game_over_popup.dart';

class GameLogicService {
  int score = 0;
  int level = 1;
  int balloonsPopped = 0; // Track the number of balloons popped per level
  int balloonsRequired = 5; // Balloons required to level up
  double timeLeft = 10.0; // Start with 10 seconds for more urgency
  List<Balloon> balloons = [];
  Timer? gameTimer;
  Timer? balloonGeneratorTimer;
  BuildContext? context; // To store the context passed from GameScreen

  Color timeLeftColor = Colors.red; // Default time left color

  InterstitialAd? _interstitialAd;
  bool isAdRemoved = false;

  final List<String> balloonImages = [
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

  final List<String> timeIcons = [
    'assets/images/icons/add_time.png', // Icon to add time
    'assets/images/icons/subtract_time.png', // Icon to subtract time
  ];

  void removeAds() {
    isAdRemoved = true;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1135480968301432~9313890103', // Test Ad Unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd?.setImmersiveMode(true);
          print('InterstitialAd loaded successfully');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && !isAdRemoved) {
      _interstitialAd?.show();
      _interstitialAd = null;
    }
  }

  void startGame(Function updateState, BuildContext context) {
    this.context = context; // Store the context for navigation later
    // Generate balloons at intervals
    balloonGeneratorTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      generateBalloon(updateState);
    });

    // Update the game state and timer
    gameTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      updateGameState(updateState);
    });
  }

  void generateBalloon(Function updateState) {
    final random = Random();
    final size = random.nextDouble() * 70 + 80; // Increased size: 80 to 150
    final xPosition =
        random.nextDouble() * 800; // Replace with MediaQuery for dynamic width

    // Select a random balloon image from the list
    final balloonImage = balloonImages[random.nextInt(balloonImages.length)];

    // Determine if the balloon will add or subtract time
    double timeChange = 0.0;
    String? timeIcon;

    // Check if the balloon is the trick balloon
    if (balloonImage == 'assets/images/balloons/balloon_trick.png') {
      // Trick balloon has no time change or icon
      timeChange = 0.0;
    } else {
      final isTimeBalloon = random.nextBool();
      timeChange = isTimeBalloon
          ? (random.nextBool() ? 2.0 : -2.0)
          : 0.0; // Add or subtract 2 seconds

      // Select the appropriate icon
      if (timeChange != 0.0) {
        timeIcon = timeChange > 0 ? timeIcons[0] : timeIcons[1];
      }
    }

    final balloon = Balloon(
      imagePath: balloonImage,
      size: size,
      position: Offset(
          xPosition, 600 - size), // Replace with MediaQuery for dynamic height
      points: size.toInt(),
      timeChange: timeChange,
      iconPath: timeIcon,
    );

    balloons.add(balloon);
    updateState();
  }

  void updateGameState(Function updateState) {
    timeLeft -= 0.1;

    // Check if time has run out
    if (timeLeft <= 0) {
      timeLeft = 0; // Prevent the timer from showing negative values
      print('Navigating to game over screen with score: $score');
      endGame();
      return;
    }

    // Check if the player has leveled up
    if (balloonsPopped >= balloonsRequired) {
      levelUp();
    }

    // Update balloon positions
    updateBalloonPositions();

    updateState();
  }

  void levelUp() {
    level++;
    balloonsPopped = 0; // Reset the count for the new level
    balloonsRequired +=
        3; // Increase the number of balloons needed for the next level

    // Adjust the balloon generation speed to increase difficulty
    balloonGeneratorTimer?.cancel();
    balloonGeneratorTimer = Timer.periodic(
      Duration(
          milliseconds: max(
              500 - level * 50, 100)), // Speed up the game as levels increase
      (timer) {
        generateBalloon(() {});
      },
    );
  }

  void updateBalloonPositions() {
    balloons = balloons.map((balloon) {
      final newY = balloon.position.dy - 5;
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
    // If the balloon is the trick balloon, end the game immediately
    if (balloon.imagePath == 'assets/images/balloons/balloon_trick.png') {
      endGame();
      return;
    }

    // Debugging: Ensure the balloon is in the list before trying to remove it
    print("Balloon exists: ${balloons.contains(balloon)}");

    score += balloon.points;
    balloonsPopped++;

    // Only decrease time if the balloon has a negative time change
    if (balloon.timeChange < 0.0) {
      timeLeft += balloon.timeChange;
      _showTimeChangeFeedback(false, updateState);
    } else if (balloon.timeChange > 0.0) {
      // Increase time if the balloon has a positive time change
      timeLeft += balloon.timeChange;
      _showTimeChangeFeedback(true, updateState);
    }

    // Remove the balloon and update the state
    balloons.remove(balloon);
    print("Balloon removed, remaining balloons: ${balloons.length}");
    updateState();
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
  }
}

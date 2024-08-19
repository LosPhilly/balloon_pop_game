import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/balloon_model.dart';
import '../widgets/game_over_popup.dart'; // Import the game over pop-up widget

class GameLogicService {
  int score = 0;
  int level = 1;
  int balloonsPopped = 0; // Track the number of balloons popped per level
  int balloonsRequired = 5; // Balloons required to level up
  double timeLeft = 5.0; // Start with 10 seconds for more urgency
  List<Balloon> balloons = [];
  Timer? gameTimer;
  Timer? balloonGeneratorTimer;
  BuildContext? context; // To store the context passed from GameScreen

  InterstitialAd? _interstitialAd;
  bool isAdRemoved = false;

  final List<String> balloonImages = [
    'assets/images/balloons/balloon_red.png',
    'assets/images/balloons/balloon_blue.png',
    // Add more balloon image paths here
  ];

  void removeAds() {
    isAdRemoved = true;
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-1135480968301432~9313890103', // Test Ad Unit ID: 'ca-app-pub-3940256099942544~1033173712'  > Real ID : ca-app-pub-1135480968301432~9313890103
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
      loadInterstitialAd();
    }
  }

  void startGame(Function updateState, BuildContext context) {
    this.context = context; // Store the context for navigation later
    loadInterstitialAd(); // Load ad when starting the game
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
    final size =
        random.nextDouble() * 50 + 50; // Random size between 50 and 100
    final xPosition =
        random.nextDouble() * 800; // Replace with MediaQuery for dynamic width

    // Select a random balloon image from the list
    final balloonImage = balloonImages[random.nextInt(balloonImages.length)];

    final balloon = Balloon(
      imagePath: balloonImage,
      size: size,
      position: Offset(
          xPosition, 600 - size), // Replace with MediaQuery for dynamic height
      points: size.toInt(),
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
      );
    }).toList();

    // Remove balloons that reached the top
    balloons.removeWhere((balloon) => balloon.position.dy < 0);
  }

  void popBalloon(Balloon balloon, Function updateState) {
    score += balloon.points;
    balloonsPopped++;
    timeLeft += 1; // Add 1 second for each balloon popped for more urgency
    balloons.remove(balloon);
    updateState();
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
              // Restart the game
              Navigator.pushReplacementNamed(context, '/game');
            },
            onViewLeaderboard: () {
              Navigator.of(context).pop(); // Close the dialog
              // Navigate to the leaderboard
              Navigator.pushReplacementNamed(context, '/leaderboard');
            },
            onBackToMenu: () {
              Navigator.of(context).pop(); // Close the dialog
              // Navigate back to the menu
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
    showInterstitialAd(); // Show the ad after the game ends

    showGameOverPopup(); // Show the game over pop-up instead of navigating to another screen
  }
}

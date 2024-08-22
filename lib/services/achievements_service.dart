import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define the list of all achievements
  final List<Map<String, dynamic>> allAchievements = [
    {
      'name': 'First Pop!',
      'description': 'Pop your first balloon',
      'unlocked': false,
    },
    {
      'name': 'Pop Master',
      'description': 'Pop 100 balloons',
      'unlocked': false,
    },
    {
      'name': 'Speed Demon',
      'description': 'Reach level 5 in under 2 minutes',
      'unlocked': false,
    },
    {
      'name': 'Time Keeper',
      'description': 'Keep the timer above 20 seconds for 3 levels',
      'unlocked': false,
    },
    {
      'name': 'Pop Pro',
      'description': 'Pop 500 balloons',
      'unlocked': false,
    },
    {
      'name': 'Balloon Buster',
      'description': 'Pop 1000 balloons',
      'unlocked': false,
    },
    {
      'name': 'Level Crusher',
      'description': 'Reach level 10',
      'unlocked': false,
    },
    {
      'name': 'Survivor',
      'description': 'Play 5 games without losing',
      'unlocked': false,
    },
    {
      'name': 'Pop Legend',
      'description': 'Score over 1000 points in a single game',
      'unlocked': false,
    },
    // Add more achievements here as needed
  ];

  // Method to get the list of achievements for the current user
  Future<List<Map<String, dynamic>>> getAchievements() async {
    User? user = _auth.currentUser;

    if (user == null) {
      // If the user is not logged in, return the full list with all achievements locked
      return allAchievements;
    }

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // If the user document doesn't exist, return the full list with all achievements locked
      return allAchievements;
    }

    List<dynamic> achievementsData = userDoc.data()?['achievements'] ?? [];

    // Ensure that all achievements are present in Firestore
    await _ensureAchievementsConsistency(achievementsData, user.uid);

    // Map the unlocked achievements to the full list of achievements
    List<Map<String, dynamic>> updatedAchievements =
        allAchievements.map((achievement) {
      bool isUnlocked = achievementsData.any((unlockedAchievement) =>
          unlockedAchievement['name'] == achievement['name']);
      return {
        'name': achievement['name'],
        'description': achievement['description'],
        'unlocked': isUnlocked,
      };
    }).toList();

    return updatedAchievements;
  }

  Future<void> unlockAchievement(String name, String description) async {
    User? user = _auth.currentUser;

    if (user == null) return; // Do nothing if the user is not logged in

    DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

    DocumentSnapshot userDoc = await userDocRef.get();

    // Ensure the document data is properly formatted
    Map<String, dynamic> userData =
        userDoc.data() as Map<String, dynamic>? ?? {};

    List<dynamic> achievementsData = userData['achievements'] ?? [];

    // Check if the achievement is already unlocked
    bool alreadyUnlocked = achievementsData.any((achievement) =>
        achievement['name'] == name && achievement['unlocked'] == true);

    if (!alreadyUnlocked) {
      achievementsData.add({
        'name': name,
        'description': description,
        'unlocked': true,
      });

      // Update the user's achievements in Firestore
      await userDocRef.update({'achievements': achievementsData});
      print('Achievement $name unlocked and updated in Firestore');
    } else {
      print('Achievement $name is already unlocked');
    }
  }

  // Method to ensure all achievements are present in Firestore
  Future<void> _ensureAchievementsConsistency(
      List<dynamic> achievementsData, String userId) async {
    List<Map<String, dynamic>> missingAchievements = [];

    for (var achievement in allAchievements) {
      bool existsInFirestore = achievementsData.any(
        (unlocked) => unlocked['name'] == achievement['name'],
      );

      if (!existsInFirestore) {
        missingAchievements.add({
          'name': achievement['name'],
          'description': achievement['description'],
          'unlocked': false,
        });
      }
    }

    if (missingAchievements.isNotEmpty) {
      // Add missing achievements to Firestore
      achievementsData.addAll(missingAchievements);
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'achievements': achievementsData});
    }
  }

  // Method to check for achievements based on the current score and stats
  Future<void> checkForAchievements(
      int score, int starBalloonsCollected) async {
    // Example achievements logic
    if (score >= 1000) {
      await unlockAchievement(
          'Pop Legend', 'Score over 1000 points in a single game');
    }

    if (starBalloonsCollected >= 10) {
      await unlockAchievement('Star Collector', 'Collect 10 star balloons');
    }

    // Add more achievement checks here as needed
  }
}

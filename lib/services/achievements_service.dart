import 'package:shared_preferences/shared_preferences.dart';

class AchievementsService {
  // Method to get the list of achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? achievementsData = prefs.getStringList('achievements');

    if (achievementsData == null) {
      return [];
    }

    return achievementsData.map((entry) {
      final parts = entry.split(':');
      return {
        'name': parts[0],
        'description': parts[1],
        'unlocked': parts[2] == 'true'
      };
    }).toList();
  }

  // Method to unlock a specific achievement
  Future<void> unlockAchievement(String name, String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? achievementsData = prefs.getStringList('achievements') ?? [];

    // Check if the achievement is already unlocked
    bool alreadyUnlocked =
        achievementsData.any((entry) => entry.startsWith('$name:'));

    if (!alreadyUnlocked) {
      achievementsData.add('$name:$description:true');
      prefs.setStringList('achievements', achievementsData);
    }
  }

  // Method to check for achievements based on the current score
  Future<void> checkForAchievements(
      int score, int starBalloonsCollected) async {
    // Example achievements logic
    if (score >= 1000) {
      await unlockAchievement('Score 1000', 'Reach a score of 1000');
    }

    if (starBalloonsCollected >= 10) {
      await unlockAchievement('Star Collector', 'Collect 10 star balloons');
    }

    // Add more achievement checks here as needed
  }
}

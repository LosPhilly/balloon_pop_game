import 'package:shared_preferences/shared_preferences.dart';

class AchievementsService {
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

  Future<void> unlockAchievement(String name, String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? achievementsData = prefs.getStringList('achievements') ?? [];

    achievementsData.add('$name:$description:true');
    prefs.setStringList('achievements', achievementsData);
  }
}

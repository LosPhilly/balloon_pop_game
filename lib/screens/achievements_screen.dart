import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/achievement_widget.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // The list of potential achievements
  final List<Map<String, dynamic>> allAchievements = [
    {
      'title': 'First Pop!',
      'description': 'Pop your first balloon',
      'isUnlocked': false
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

  Future<void> _loadUserAchievements() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      List<dynamic> unlockedAchievements = userDoc['achievements'] ?? [];

      // Update the achievements in Firestore if they are missing the "unlocked" field
      /* for (var achievement in allAchievements) {
        var existsInFirestore = unlockedAchievements.any(
          (unlocked) => unlocked['name'] == achievement['title'],
        );
        if (!existsInFirestore) {
          // Add missing achievement to Firestore with the unlocked status
          unlockedAchievements.add({
            'name': achievement['title'],
            'description': achievement['description'],
            'unlocked': false,
          });
        }
      } */

      // Update the Firestore document with any new achievements
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'achievements': unlockedAchievements});

      // Update the UI state
      setState(() {
        for (var achievement in allAchievements) {
          var matchingUnlockedAchievement = unlockedAchievements.firstWhere(
            (unlocked) => unlocked['name'] == achievement['title'],
            orElse: () => null,
          );
          if (matchingUnlockedAchievement != null) {
            achievement['isUnlocked'] = matchingUnlockedAchievement['unlocked'];
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              isNightMode
                  ? 'assets/images/dark/sky_dark_1.png'
                  : 'assets/images/light/sky_1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Achievements content
          Positioned.fill(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      backgroundColor: Colors.purpleAccent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: allAchievements.length,
                      itemBuilder: (context, index) {
                        return AchievementWidget(
                          title: allAchievements[index]['title'],
                          description: allAchievements[index]['description'],
                          isUnlocked: allAchievements[index]['isUnlocked'],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool isUnlocked;

  AchievementWidget({
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnlocked ? Colors.lightGreen : Colors.grey[300],
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.check_circle : Icons.lock,
              color: isUnlocked ? Colors.white : Colors.grey,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isUnlocked ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

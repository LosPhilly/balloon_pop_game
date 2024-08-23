import 'package:balloon_pop/providers/auth_provider.dart';
import 'package:balloon_pop/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/theme_provider.dart';

// Manual capitalization function
String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

class ProfilePage extends StatelessWidget {
  final Map<String, IconData> balloonIcons = {
    'orange': Icons.circle,
    'gold': Icons.star,
    'red': Icons.circle,
    'green': Icons.circle,
    'blue': Icons.circle,
    'yellow': Icons.circle,
    'purple': Icons.circle,
    'silver': Icons.circle,
    'star': Icons.star_border,
    'trick': Icons.flash_on,
  };

  final Map<String, Color> balloonColors = {
    'orange': Colors.orange,
    'gold': Colors.amber,
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
    'silver': Colors.grey,
    'star': Colors.amberAccent,
    'trick': Colors.deepPurpleAccent,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
          // Profile content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 100), // Add padding at the top
                child: Center(
                  child: authProvider.isGuest
                      ? _buildGuestView(context, isNightMode)
                      : FutureBuilder<DocumentSnapshot>(
                          future: authProvider.getUserStats(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error loading profile'));
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(
                                  child: Text('No profile data found'));
                            }

                            final userData = snapshot.data!;

                            return _buildProfileView(
                                context, userData, isNightMode);
                          },
                        ),
                ),
              ),
            ),
          ),
          // Floating back button
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, bool isNightMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.person_outline,
          size: 100,
          color: isNightMode ? Colors.white70 : Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          'Guest User',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isNightMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'You are currently logged in as a guest.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: isNightMode ? Colors.white70 : Colors.grey,
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signup');
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Sign Up',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView(
      BuildContext context, DocumentSnapshot userData, bool isNightMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: isNightMode ? Colors.grey[800] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.pinkAccent,
                    child: Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                  title: Text(
                    userData['username'],
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isNightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    userData['email'],
                    style: TextStyle(
                      fontSize: 20,
                      color: isNightMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        _buildStatCard('Total Score', userData['score'].toString(),
            Icons.emoji_events, isNightMode),
        SizedBox(height: 10),
        _buildStatCard('Current Level', userData['level'].toString(),
            Icons.star_rate, isNightMode),
        SizedBox(height: 20),
        _buildBalloonStats(userData['balloonStats'], isNightMode),
        SizedBox(height: 20),
        // Share button
        ElevatedButton.icon(
          onPressed: () {
            _shareStats(userData);
          },
          icon: Icon(Icons.share, color: Colors.white),
          label: Text(
            'Share My Stats',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, bool isNightMode) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isNightMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.pinkAccent,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 20,
                      color: isNightMode ? Colors.white70 : Colors.grey[700]),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isNightMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalloonStats(
      Map<String, dynamic> balloonStats, bool isNightMode) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: isNightMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balloon Stats',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: balloonStats.entries.map((entry) {
                final balloonType =
                    entry.key.replaceAll('balloon_', '').toLowerCase();
                final balloonIcon = balloonIcons[balloonType];
                final balloonColor = balloonColors[balloonType];

                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: balloonColor,
                    child: Icon(balloonIcon, color: Colors.white, size: 20),
                  ),
                  label: Text(
                    '${capitalize(balloonType)}: ${entry.value}',
                    style: TextStyle(
                        fontSize: 18,
                        color: isNightMode ? Colors.white : Colors.blueAccent),
                  ),
                  backgroundColor: isNightMode
                      ? Colors.blueGrey[700]
                      : Colors.lightBlueAccent.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _shareStats(DocumentSnapshot userData) {
    final username = userData['username'];
    final score = userData['score'];
    final level = userData['level'];
    final balloonStats = userData['balloonStats'];

    final shareContent = StringBuffer();
    shareContent.writeln("Check out my stats on Balloon Pop Game!");
    shareContent.writeln("Username: $username");
    shareContent.writeln("Total Score: $score");
    shareContent.writeln("Current Level: $level");
    shareContent.writeln("Balloon Stats:");
    balloonStats.forEach((key, value) {
      shareContent.writeln("${capitalize(key)}: $value");
    });

    Share.share(shareContent.toString());
  }
}

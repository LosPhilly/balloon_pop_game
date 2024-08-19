import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/sign_up_screen.dart';
//import 'screens/login_screen.dart';  // Import the Login screen
import 'screens/profile_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/game':
        return MaterialPageRoute(builder: (_) => GameScreen());
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => LeaderboardScreen());
      case '/achievements':
        return MaterialPageRoute(builder: (_) => AchievementsScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case '/game_over':
        return MaterialPageRoute(builder: (_) => GameOverScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      /* case '/login':  // Define the Login route
        return MaterialPageRoute(builder: (_) => LoginScreen());
      */
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}

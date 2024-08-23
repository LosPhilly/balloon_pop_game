import 'package:balloon_pop/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/user_sign_up_screen.dart'; // Import the UserSignUpScreen

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
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case '/user_signup':
        return MaterialPageRoute(
            builder: (_) =>
                UserSignUpScreen()); // Add the route for UserSignUpScreen
      case '/login': // Define the Login route
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(builder: (_) => HomeScreen());
    }
  }
}

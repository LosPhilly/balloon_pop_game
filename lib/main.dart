import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'routes.dart';
import 'providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'providers/auth_provider.dart'; // Import your AuthProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isNightMode = prefs.getBool('isNightMode') ?? false;
  await Firebase.initializeApp();
  MobileAds.instance.initialize(); // Initialize Google Mobile Ads

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isNightMode)),
        ChangeNotifierProvider(
            create: (_) => AuthProvider()), // AuthProvider added
      ],
      child: BalloonPopGame(),
    ),
  );
}

class BalloonPopGame extends StatefulWidget {
  @override
  _BalloonPopGameState createState() => _BalloonPopGameState();
}

class _BalloonPopGameState extends State<BalloonPopGame> {
  @override
  void initState() {
    super.initState();

    // Listen to the purchase stream for in-app purchases
    InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          // Purchase completed
          if (purchaseDetails.productID == 'remove_ads') {
            _removeAds(); // Call your method to remove ads
          }
        }
      }
    });
  }

  void _removeAds() async {
    // Implement your logic to remove ads, such as setting a flag in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adsRemoved', true);
    setState(() {
      // This will force a rebuild and hide the ads if any
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        // Check if the user is already logged in
        bool isLoggedIn = authProvider.user != null;
        bool signedInAsGuest = authProvider.isGuest;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Balloon Pop Game',
          theme: themeProvider.themeData,
          initialRoute: isLoggedIn && !signedInAsGuest ? '/home' : '/signup',
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

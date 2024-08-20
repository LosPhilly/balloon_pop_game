import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.white,
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
          // Floating settings options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFloatingHeader(context, 'Settings', isNightMode),
                SizedBox(height: 30),
                _buildFloatingOption(
                  context,
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  value: true,
                  onChanged: (value) {
                    // Handle sound effects toggle
                  },
                  isNightMode: isNightMode,
                ),
                _buildFloatingOption(
                  context,
                  icon: Icons.music_note,
                  title: 'Background Music',
                  value: true,
                  onChanged: (value) {
                    // Handle background music toggle
                  },
                  isNightMode: isNightMode,
                ),
                _buildFloatingOption(
                  context,
                  icon: Icons.nightlight_round,
                  title: 'Night Mode',
                  value: isNightMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  isNightMode: isNightMode,
                ),
                _buildFloatingOption(
                  context,
                  icon: Icons.remove_circle,
                  title: 'Remove Ads',
                  onTap: () async {
                    // Handle in-app purchase for removing ads
                    final available =
                        await InAppPurchase.instance.isAvailable();
                    if (available) {
                      const Set<String> _kIds = {'remove_ads'};
                      final ProductDetailsResponse response =
                          await InAppPurchase.instance
                              .queryProductDetails(_kIds);
                      if (response.notFoundIDs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Product not found'),
                        ));
                        return;
                      }
                      final List<ProductDetails> products =
                          response.productDetails;
                      if (products.isNotEmpty) {
                        final PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: products[0],
                        );
                        InAppPurchase.instance
                            .buyNonConsumable(purchaseParam: purchaseParam);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('In-App Purchases are not available'),
                      ));
                    }
                  },
                  isNightMode: isNightMode,
                  onChanged: (bool) {},
                ),
                Spacer(),
                _buildFloatingActionButton(
                  context,
                  icon: Icons.logout,
                  label: 'Log Out',
                  color: Colors.redAccent,
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(
                        'isLoggedIn', false); // Reset login status
                    await authProvider.signOut(); // Sign out the user
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                ),
                SizedBox(height: 10),
                _buildFloatingActionButton(
                  context,
                  icon: Icons.arrow_back,
                  label: 'Back',
                  color: isNightMode ? Colors.white : Colors.black,
                  textColor: isNightMode ? Colors.black : Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(
      BuildContext context, String title, bool isNightMode) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isNightMode ? Colors.grey[900] : Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isNightMode ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingOption(BuildContext context,
      {required IconData icon,
      required String title,
      bool? value,
      required Function(bool) onChanged,
      required bool isNightMode,
      Function? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: onTap as void Function()?,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: isNightMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: isNightMode ? Colors.white : Colors.black),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: isNightMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (value != null)
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor:
                      isNightMode ? Colors.lightGreenAccent : Colors.blueAccent,
                  inactiveThumbColor: isNightMode ? Colors.grey : Colors.grey,
                  inactiveTrackColor:
                      isNightMode ? Colors.grey[800] : Colors.grey[300],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      Color? textColor,
      required VoidCallback onPressed}) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor ?? Colors.white),
        label: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: Colors.black38,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isNightMode ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(
                'Sound Effects',
                style: TextStyle(
                  color: isNightMode ? Colors.white : Colors.black,
                ),
              ),
              value: true,
              onChanged: (value) {
                // Handle sound effects toggle
              },
            ),
            SwitchListTile(
              title: Text(
                'Background Music',
                style: TextStyle(
                  color: isNightMode ? Colors.white : Colors.black,
                ),
              ),
              value: true,
              onChanged: (value) {
                // Handle background music toggle
              },
            ),
            SwitchListTile(
              title: Text(
                'Night Mode',
                style: TextStyle(
                  color: isNightMode ? Colors.white : Colors.black,
                ),
              ),
              value: isNightMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            ListTile(
              title: Text(
                'Remove Ads',
                style: TextStyle(
                  color: isNightMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                Icons.remove_circle,
                color: isNightMode ? Colors.redAccent : Colors.blueAccent,
              ),
              onTap: () async {
                // Start the in-app purchase process to remove ads
                final available = await InAppPurchase.instance.isAvailable();
                if (available) {
                  const Set<String> _kIds = {
                    'remove_ads'
                  }; // Replace with your product ID
                  final ProductDetailsResponse response =
                      await InAppPurchase.instance.queryProductDetails(_kIds);
                  if (response.notFoundIDs.isNotEmpty) {
                    // Handle the error when the product ID is not found
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Product not found'),
                    ));
                    return;
                  }
                  final List<ProductDetails> products = response.productDetails;
                  if (products.isNotEmpty) {
                    final PurchaseParam purchaseParam = PurchaseParam(
                      productDetails: products[0],
                    );
                    InAppPurchase.instance
                        .buyNonConsumable(purchaseParam: purchaseParam);
                  }
                } else {
                  // Handle the error when In-App Purchases are not available
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('In-App Purchases are not available'),
                  ));
                }
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false); // Reset login status
                Navigator.pushReplacementNamed(
                    context, '/signup'); // Navigate to sign-up/login screen
              },
              child: Text('Log Out'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

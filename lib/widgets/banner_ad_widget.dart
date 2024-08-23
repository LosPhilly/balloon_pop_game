import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-1135480968301432~9313890103', // Replace with your actual Ad Unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd != null
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : SizedBox();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

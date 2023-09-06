import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A simple way to show ads by merely providing an [adSize].
///
/// By default, this shows test ad units. When you create a real ad unit
/// in AdMob, provide its [adUnitId] to this widget's constructor.
class SimpleBannerAdWidget extends StatefulWidget {
  /// The size of the banner ad.
  final AdSize adSize;

  /// The ad unit ids to request.
  ///
  /// Defaults to the appropriate test units provided by AdMob.
  /// See https://developers.google.com/admob/android/test-ads
  /// and https://developers.google.com/admob/ios/test-ads.
  final String adUnitId;

  SimpleBannerAdWidget({
    super.key,
    required this.adSize,
    String? adUnitId,
  })  : assert(
            adSize.width > 0 && adSize.height > 0,
            "This widget only works with normal ad sizes "
            "(and not, for example, AdSize.fluid)"),
        adUnitId = adUnitId ?? _getTestUnitId(adSize);

  @override
  State<SimpleBannerAdWidget> createState() => _SimpleBannerAdWidgetState();

  /// Returns the special test unit IDs provided by AdMob.
  static String _getTestUnitId(AdSize size) {
    final isAndroid = Platform.isAndroid;

    if (size is AnchoredAdaptiveBannerAdSize) {
      // Return Adaptive Banner creatives.
      return isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741'
          : 'ca-app-pub-3940256099942544/2435281174';
    }

    // Return normal banner creatives.
    return isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
  }
}

class _SimpleBannerAdWidgetState extends State<SimpleBannerAdWidget> {
  // The banner ad to show. This is null until the ad is actually loaded.
  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    // This SizedBox widget serves double duty. Before the banner ad is loaded,
    // it serves as a placeholder. Afterwards, it makes sure this widget
    // takes exactly as much space as is needed.
    return SizedBox(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: _bannerAd != null
          // The actual ad.
          ? AdWidget(ad: _bannerAd!)
          // An empty space.
          : SizedBox(),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(
        // You can give more context to AdMob so that it serves
        // more relevant ads.
        //
        // TODO: replace keywords below or remove the line completely
        keywords: ['programming', 'technology', 'code'],
      ),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    );

    // Start loading.
    bannerAd.load();
  }
}

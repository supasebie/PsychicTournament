import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized AdMob service using Google test IDs for development.
/// Replace IDs with your real AdMob unit IDs before release.
///
/// References:
/// - Banner example: https://github.com/googleads/googleads-mobile-flutter/blob/main/samples/admob/banner_example/README.md
/// - Interstitial example: https://github.com/googleads/googleads-mobile-flutter/blob/main/samples/admob/interstitial_example/README.md
class AdService {
  AdService._();

  // Test Ad Unit IDs from Google (safe for development)
  // Android
  static const String _androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  // iOS
  static const String _iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) return _androidBannerTestId;
    if (Platform.isIOS) return _iosBannerTestId;
    // Fallback for unsupported platforms (e.g., web, desktop) - use Android test ID in debug
    return kDebugMode ? _androidBannerTestId : '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return _androidInterstitialTestId;
    if (Platform.isIOS) return _iosInterstitialTestId;
    return kDebugMode ? _androidInterstitialTestId : '';
  }

  /// Create a banner ad. Caller must call load() and dispose() it.
  static BannerAd createBanner({
    AdSize size = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      size: size,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded?.call(ad),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad(ad, error);
          } else {
            debugPrint('BannerAd failed to load: $error');
          }
        },
      ),
    );
  }

  /// Load an interstitial ad using official callback API.
  static Future<InterstitialAd?> loadInterstitial({
    void Function(InterstitialAd)? onLoaded,
    void Function(LoadAdError)? onFailedToLoad,
  }) async {
    try {
      InterstitialAd? loadedAd;
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            loadedAd = ad;
            onLoaded?.call(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            onFailedToLoad?.call(error);
            debugPrint('InterstitialAd failed to load: $error');
          },
        ),
      );
      return loadedAd;
    } catch (e) {
      debugPrint('Interstitial load error (unexpected): $e');
      return null;
    }
  }
}

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // FIX: Replaced invalid 'xxxxxxxx' placeholders with official Google test IDs.
  // These work immediately without an AdMob account.
  // Replace with your real IDs from the ADMOB secrets when ready for production.
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner Ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('Rewarded Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed: $error');
        },
      ),
    );
  }

  void showRewardedAd(Function(RewardItem) onRewardEarned) {
    if (_rewardedAd == null) return;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onRewardEarned(reward),
    );
    _rewardedAd = null;
  }

  BannerAd? get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

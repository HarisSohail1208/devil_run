import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MonetizationService extends ChangeNotifier {
  MonetizationService._();

  static final instance = MonetizationService._();

  static const _productionRewardedId = 'ca-app-pub-4950586958473002/7925707578';
  static const _productionInterstitialId =
      'ca-app-pub-4950586958473002/6748357279';
  static const _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  bool get rewardedReady => _rewardedAd != null;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  String get _rewardedId =>
      kDebugMode ? _testRewardedId : _productionRewardedId;
  String get _interstitialId =>
      kDebugMode ? _testInterstitialId : _productionInterstitialId;

  Future<void> initialize() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
        _privacyOptionsRequired =
            await ConsentInformation.instance
                .getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
        if (_canRequestAds) await _initializeAds();
        completer.complete();
      },
      (error) async {
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
        if (_canRequestAds) await _initializeAds();
        completer.complete();
      },
    );
    await completer.future;
  }

  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    _loadRewarded();
    _loadInterstitial();
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          notifyListeners();
        },
      ),
    );
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<bool> showRewarded() async {
    final ad = _rewardedAd;
    if (!_canRequestAds || ad == null) return false;
    _rewardedAd = null;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        _loadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (_, reward) => earned = true);
    return earned;
  }

  Future<void> showLevelBreakInterstitial() async {
    final ad = _interstitialAd;
    if (!_canRequestAds || ad == null) return;
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        _loadInterstitial();
      },
    );
    await ad.show();
  }

  Future<void> showPrivacyOptions() async {
    final available = await ConsentInformation.instance
        .isConsentFormAvailable();
    if (!available) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}

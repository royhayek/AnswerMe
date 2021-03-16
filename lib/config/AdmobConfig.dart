import 'dart:io';

//////////////////////////////////////////
///       ADMOB CONFIGUGRATION         ///
//////////////////////////////////////////

class AdmobConfig {
  // Banners Ad Ids
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Android Banner Ad Id
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS Banner Ad Id
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw new UnsupportedError("Unsupported platform");
  }

  // Interstitial Ad Ids
  static String get interstitualAdUnitId {
    if (Platform.isAndroid) {
      // Android Interstitial Ad Id
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // iOS Interstitial Ad Id
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw new UnsupportedError("Unsupported platform");
  }
}

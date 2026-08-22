// File generated for Firebase Core options.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Note: To connect to your specific production Firebase project,
/// run `flutterfire configure` or place `google-services.json` in `android/app/`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForHomeStockResearchPrototype',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'homestock-prototype',
    authDomain: 'homestock-prototype.firebaseapp.com',
    storageBucket: 'homestock-prototype.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForHomeStockResearchPrototype',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'homestock-prototype',
    storageBucket: 'homestock-prototype.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForHomeStockResearchPrototype',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'homestock-prototype',
    storageBucket: 'homestock-prototype.appspot.com',
    iosBundleId: 'io.homestock.app',
  );
}

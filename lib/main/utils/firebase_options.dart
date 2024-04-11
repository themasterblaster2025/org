import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD63jDs8zx_kV-bfwddX6th3bH1CMj-gEk',
    appId: '1:12372904825:android:855f0fd5c9191baa22fda8',
    messagingSenderId: '12372904825',
    projectId: 'mightydelivery-10da9',
    storageBucket: 'mightydelivery-10da9.appspot.com',
  );
}

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured. Use FlutterFire CLI to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS is not configured. Add GoogleService-Info.plist to add iOS support.',
        );
      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSJcNM6495xI9I3XgZwIB12_h2-5C6FAA',
    appId: '1:258088385426:android:c4d14ea40238da8429df4b',
    messagingSenderId: '258088385426',
    projectId: 'notesapp-1b887',
    storageBucket: 'notesapp-1b887.firebasestorage.app',
  );
}
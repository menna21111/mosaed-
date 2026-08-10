import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for project `mosaed-b7338` (customer app `com.mossad`).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCU6HT_mHnEz69tJmUlnQT_ZS26zoLNQWU',
    appId: '1:247084842186:android:d960006e3985d6de8d4833',
    messagingSenderId: '247084842186',
    projectId: 'mosaed-b7338',
    storageBucket: 'mosaed-b7338.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9Z_3yIzGdVTuPL7e-g9rGrX2ODrquaew',
    appId: '1:247084842186:ios:138d64b089779cda8d4833',
    messagingSenderId: '247084842186',
    projectId: 'mosaed-b7338',
    storageBucket: 'mosaed-b7338.firebasestorage.app',
    iosBundleId: 'com.mossad',
  );
}

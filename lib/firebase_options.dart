import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBv3aOdo7j0BVQFU4dJ_I5MMy4anyqrqhE',
    appId: '1:505388994229:web:a620f3735bb1dc6420f8fc',
    messagingSenderId: '505388994229',
    projectId: 'teentalk-31e45',
    authDomain: 'teentalk-31e45.firebaseapp.com',
    storageBucket: 'teentalk-31e45.firebasestorage.app',
    measurementId: 'G-0KPB6VFN4J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBv3aOdo7j0BVQFU4dJ_I5MMy4anyqrqhE',
    appId: '1:505388994229:android:placeholder',
    messagingSenderId: '505388994229',
    projectId: 'teentalk-31e45',
    authDomain: 'teentalk-31e45.firebaseapp.com',
    storageBucket: 'teentalk-31e45.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBv3aOdo7j0BVQFU4dJ_I5MMy4anyqrqhE',
    appId: '1:505388994229:ios:placeholder',
    messagingSenderId: '505388994229',
    projectId: 'teentalk-31e45',
    authDomain: 'teentalk-31e45.firebaseapp.com',
    storageBucket: 'teentalk-31e45.firebasestorage.app',
    iosBundleId: 'com.teentalk.teenTalkApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBv3aOdo7j0BVQFU4dJ_I5MMy4anyqrqhE',
    appId: '1:505388994229:ios:placeholder',
    messagingSenderId: '505388994229',
    projectId: 'teentalk-31e45',
    authDomain: 'teentalk-31e45.firebaseapp.com',
    storageBucket: 'teentalk-31e45.firebasestorage.app',
    iosBundleId: 'com.teentalk.teenTalkApp',
  );
}

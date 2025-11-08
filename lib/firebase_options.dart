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
    apiKey: 'AIzaSyDummyKey',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'teentalk-demo',
    authDomain: 'teentalk-demo.firebaseapp.com',
    storageBucket: 'teentalk-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKey',
    appId: '1:123456789:android:abcdef',
    messagingSenderId: '123456789',
    projectId: 'teentalk-demo',
    authDomain: 'teentalk-demo.firebaseapp.com',
    storageBucket: 'teentalk-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKey',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'teentalk-demo',
    authDomain: 'teentalk-demo.firebaseapp.com',
    storageBucket: 'teentalk-demo.appspot.com',
    iosBundleId: 'com.example.teenTalkApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKey',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'teentalk-demo',
    authDomain: 'teentalk-demo.firebaseapp.com',
    storageBucket: 'teentalk-demo.appspot.com',
    iosBundleId: 'com.example.teenTalkApp',
  );
}

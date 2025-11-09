import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
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
}

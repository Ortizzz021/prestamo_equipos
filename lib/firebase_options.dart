// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB7Wbi_9Kli863b3EEzUXsUp2zS3k1wCtM',
    appId: '1:61168774453:web:7640cd1240b9d320e3707c',
    messagingSenderId: '61168774453',
    projectId: 'prestamo-equipos-36c3c',
    authDomain: 'prestamo-equipos-36c3c.firebaseapp.com',
    storageBucket: 'prestamo-equipos-36c3c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2NE4IOi6lbhLYOLdbDOUfCdle32B7H58',
    appId: '1:61168774453:android:4bbf36b865c32122e3707c',
    messagingSenderId: '61168774453',
    projectId: 'prestamo-equipos-36c3c',
    storageBucket: 'prestamo-equipos-36c3c.firebasestorage.app',
  );
}

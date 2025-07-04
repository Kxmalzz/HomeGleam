// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyCHoCh6jIA-gpbNvKHkOx8Pkj1E2_-B04w',
    appId: '1:1042200061404:web:db5603673f313e48301b19',
    messagingSenderId: '1042200061404',
    projectId: 'my-pro-b993c',
    authDomain: 'my-pro-b993c.firebaseapp.com',
    storageBucket: 'my-pro-b993c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCae-5atS4NbMoRLPFkmC-CWXP9VczAKEY',
    appId: '1:1042200061404:android:cf8e0de4c67d5442301b19',
    messagingSenderId: '1042200061404',
    projectId: 'my-pro-b993c',
    storageBucket: 'my-pro-b993c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADRwbj4yMAivOdmUOkE4YkVZZ1UWNDcrg',
    appId: '1:1042200061404:ios:7df2041601527612301b19',
    messagingSenderId: '1042200061404',
    projectId: 'my-pro-b993c',
    storageBucket: 'my-pro-b993c.firebasestorage.app',
    iosBundleId: 'com.example.myFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADRwbj4yMAivOdmUOkE4YkVZZ1UWNDcrg',
    appId: '1:1042200061404:ios:7df2041601527612301b19',
    messagingSenderId: '1042200061404',
    projectId: 'my-pro-b993c',
    storageBucket: 'my-pro-b993c.firebasestorage.app',
    iosBundleId: 'com.example.myFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCHoCh6jIA-gpbNvKHkOx8Pkj1E2_-B04w',
    appId: '1:1042200061404:web:2a6d6604edaf388d301b19',
    messagingSenderId: '1042200061404',
    projectId: 'my-pro-b993c',
    authDomain: 'my-pro-b993c.firebaseapp.com',
    storageBucket: 'my-pro-b993c.firebasestorage.app',
  );
}

// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyD0Fsplk22A_QAmBmbJUpyU296vQa_6uFI',
    appId: '1:929968742675:web:bed1cb752fe4dfdf9e7ae6',
    messagingSenderId: '929968742675',
    projectId: 'school-3d8cf',
    authDomain: 'school-3d8cf.firebaseapp.com',
    storageBucket: 'school-3d8cf.appspot.com',
    measurementId: 'G-VQ95X04BY4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuYaVesRIiOBqC1azRKyKwrOXpSq9L-XM',
    appId: '1:929968742675:android:7ef1174bf15211789e7ae6',
    messagingSenderId: '929968742675',
    projectId: 'school-3d8cf',
    storageBucket: 'school-3d8cf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyLEaKY_XXtSs7v_meozc2TVYNHPWVywQ',
    appId: '1:929968742675:ios:cfa0b70a11d028849e7ae6',
    messagingSenderId: '929968742675',
    projectId: 'school-3d8cf',
    storageBucket: 'school-3d8cf.appspot.com',
    iosClientId: '929968742675-2hu81baekhavppcia0tnnv69pfsakh6b.apps.googleusercontent.com',
    iosBundleId: 'com.example.school',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDyLEaKY_XXtSs7v_meozc2TVYNHPWVywQ',
    appId: '1:929968742675:ios:960d58343c8a88729e7ae6',
    messagingSenderId: '929968742675',
    projectId: 'school-3d8cf',
    storageBucket: 'school-3d8cf.appspot.com',
    iosClientId: '929968742675-b03p6acmhpt6rqh1c0s74n7ap2nm9f7u.apps.googleusercontent.com',
    iosBundleId: 'com.example.school.RunnerTests',
  );
}

// ignore_for_file: public_member_api_docs
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the different platforms.
///
/// Android values come from `android/app/google-services.json`. Web uses the
/// same project/sender so the app initializes on browser builds; FCM web
/// registration degrades gracefully if a dedicated web app is not registered
/// in the Firebase console.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwDjvuxw-cChEfKzGro1AWVRDKy_GtrLKM',
    appId: '1:849165391714:android:889446a95fe07d320d3e3b',
    messagingSenderId: '849165391714',
    projectId: 'socialgramokie',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwDjvuxw-cChEfKzGro1AWVRDKy_GtrLKM',
    appId: '1:849165391714:android:889446a95fe07d320d3e3b',
    messagingSenderId: '849165391714',
    projectId: 'socialgramokie',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDwDjvuxw-cChEfKzGro1AWVRDKy_GtrLKM',
    appId: '1:849165391714:android:889446a95fe07d320d3e3b',
    messagingSenderId: '849165391714',
    projectId: 'socialgramokie',
    authDomain: 'socialgramokie.firebaseapp.com',
  );
}
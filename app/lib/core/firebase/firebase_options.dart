// Archivo generado para configuración de Firebase.
// Puedes reconfigurar este archivo ejecutando: `flutterfire configure`
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
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderWebKey',
    appId: '1:1234567890:web:demoWalletAi',
    messagingSenderId: '1234567890',
    projectId: 'wallet-ai-prod',
    authDomain: 'wallet-ai-prod.firebaseapp.com',
    storageBucket: 'wallet-ai-prod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderAndroidKey',
    appId: '1:1234567890:android:demoWalletAi',
    messagingSenderId: '1234567890',
    projectId: 'wallet-ai-prod',
    storageBucket: 'wallet-ai-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderIosKey',
    appId: '1:1234567890:ios:demoWalletAi',
    messagingSenderId: '1234567890',
    projectId: 'wallet-ai-prod',
    storageBucket: 'wallet-ai-prod.appspot.com',
    iosBundleId: 'com.walletai.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderMacKey',
    appId: '1:1234567890:ios:demoWalletAi',
    messagingSenderId: '1234567890',
    projectId: 'wallet-ai-prod',
    storageBucket: 'wallet-ai-prod.appspot.com',
    iosBundleId: 'com.walletai.app',
  );
}

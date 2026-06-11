import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static const String apiKey = '';
  static const String appId = '';
  static const String messagingSenderId = '';
  static const String projectId = '';

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      TargetPlatform.windows => windows,
      TargetPlatform.linux => linux,
      TargetPlatform.fuchsia => throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for Fuchsia.',
      ),
    };
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBviPvIxakRCPdVxZXz7mf8OvYil1N2nFM',
    appId: '1:593148647403:web:20c78dff0d85bae2e22bae',
    messagingSenderId: '593148647403',
    projectId: 'todo-clean-architecture-a8e6c',
    authDomain: 'todo-clean-architecture-a8e6c.firebaseapp.com',
    storageBucket: 'todo-clean-architecture-a8e6c.firebasestorage.app',
    measurementId: 'G-97QWHDKMHB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHg3QIzEoFEobr30MghKFC95zKczn6h5U',
    appId: '1:593148647403:android:9c854c6fcb3e8529e22bae',
    messagingSenderId: '593148647403',
    projectId: 'todo-clean-architecture-a8e6c',
    storageBucket: 'todo-clean-architecture-a8e6c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuSNIKriqr8p1t7COwXdqHIkb7Dl85l0g',
    appId: '1:593148647403:ios:a9aa0f074c125601e22bae',
    messagingSenderId: '593148647403',
    projectId: 'todo-clean-architecture-a8e6c',
    storageBucket: 'todo-clean-architecture-a8e6c.firebasestorage.app',
    iosBundleId: 'com.example.flutterFirestoreWithRxdartProject',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDuSNIKriqr8p1t7COwXdqHIkb7Dl85l0g',
    appId: '1:593148647403:ios:a9aa0f074c125601e22bae',
    messagingSenderId: '593148647403',
    projectId: 'todo-clean-architecture-a8e6c',
    storageBucket: 'todo-clean-architecture-a8e6c.firebasestorage.app',
    iosBundleId: 'com.example.flutterFirestoreWithRxdartProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBviPvIxakRCPdVxZXz7mf8OvYil1N2nFM',
    appId: '1:593148647403:web:7775327dd3cd7443e22bae',
    messagingSenderId: '593148647403',
    projectId: 'todo-clean-architecture-a8e6c',
    authDomain: 'todo-clean-architecture-a8e6c.firebaseapp.com',
    storageBucket: 'todo-clean-architecture-a8e6c.firebasestorage.app',
    measurementId: 'G-9Z8T0W7K80',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
  );
}

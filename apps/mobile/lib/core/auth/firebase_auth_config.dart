import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class FirebaseAuthConfig {
  const FirebaseAuthConfig({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain = '',
    this.storageBucket = '',
    this.iosBundleId = '',
    this.androidClientId = '',
    this.iosClientId = '',
    this.webClientId = '',
  });

  factory FirebaseAuthConfig.fromEnvironment() {
    return const FirebaseAuthConfig(
      apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      androidClientId: String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID'),
      iosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      webClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    );
  }

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String authDomain;
  final String storageBucket;
  final String iosBundleId;
  final String androidClientId;
  final String iosClientId;
  final String webClientId;

  bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  bool get isGoogleSignInConfigured => webClientId.isNotEmpty;

  FirebaseOptions toFirebaseOptions() {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      iosBundleId: iosBundleId.isEmpty ? null : iosBundleId,
      androidClientId: androidClientId.isEmpty ? null : androidClientId,
      iosClientId: iosClientId.isEmpty ? null : iosClientId,
    );
  }

  String? get nativeGoogleClientId {
    if (kIsWeb) return null;
    if (defaultTargetPlatform.name == 'iOS' && iosClientId.isNotEmpty) {
      return iosClientId;
    }
    return null;
  }
}

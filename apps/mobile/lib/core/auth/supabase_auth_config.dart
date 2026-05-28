import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class SupabaseAuthConfig {
  const SupabaseAuthConfig({
    required this.url,
    required this.anonKey,
    this.androidClientId = '',
    this.iosClientId = '',
    this.webClientId = '',
    this.oauthRedirectUrl = 'com.hunnybibletracker.app://login-callback/',
  });

  factory SupabaseAuthConfig.fromEnvironment() {
    return const SupabaseAuthConfig(
      url: String.fromEnvironment('SUPABASE_URL'),
      anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      androidClientId: String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID'),
      iosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      webClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    );
  }

  final String url;
  final String anonKey;
  final String androidClientId;
  final String iosClientId;
  final String webClientId;
  final String oauthRedirectUrl;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  bool get isGoogleSignInConfigured => webClientId.isNotEmpty;

  String? get nativeGoogleClientId {
    if (kIsWeb) return null;
    if (defaultTargetPlatform.name == 'iOS' && iosClientId.isNotEmpty) {
      return iosClientId;
    }
    if (defaultTargetPlatform.name == 'android' && androidClientId.isNotEmpty) {
      return androidClientId;
    }
    return null;
  }
}

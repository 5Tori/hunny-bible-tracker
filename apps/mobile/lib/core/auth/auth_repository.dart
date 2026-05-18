import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../api/hunny_api_config.dart';
import '../api/hunny_api_models.dart';
import '../../features/read/data/read_repository.dart';
import 'auth_models.dart';
import 'firebase_auth_config.dart';

/// Firebase Auth session + local profile link.
///
/// Neon remains the application database. Firebase owns authentication, and
/// `local_users.auth_user_id` stores Firebase `uid` for future sync.
class AuthRepository {
  AuthRepository({
    required FirebaseAuthConfig firebaseConfig,
    required bool firebaseReady,
    required ReadRepository readRepository,
    fb.FirebaseAuth? firebaseAuth,
    HunnyApiConfig? apiConfig,
  })  : _firebaseConfig = firebaseConfig,
        _firebaseReady = firebaseReady,
        _firebaseAuth =
            firebaseReady ? (firebaseAuth ?? fb.FirebaseAuth.instance) : null,
        _readRepository = readRepository,
        _apiConfig = apiConfig ?? HunnyApiConfig.fromEnvironment();

  final FirebaseAuthConfig _firebaseConfig;
  final bool _firebaseReady;
  final fb.FirebaseAuth? _firebaseAuth;
  final ReadRepository _readRepository;
  final HunnyApiConfig _apiConfig;

  bool get isAvailable => _firebaseReady && _firebaseAuth != null;

  bool get isApiConfigured => _apiConfig.isConfigured;

  bool get isGoogleSignInConfigured => _firebaseConfig.isGoogleSignInConfigured;

  Future<AuthSession?> refreshRemoteSession() async {
    final auth = _firebaseAuth;
    if (!_firebaseReady || auth == null) return null;
    final user = auth.currentUser;
    if (user == null) {
      await _readRepository.clearAuthLink();
      return null;
    }
    await user.reload();
    final refreshed = auth.currentUser;
    if (refreshed == null) {
      await _readRepository.clearAuthLink();
      return null;
    }
    await _syncSignedInUser(refreshed, allowApiFailure: true);
    await pushReadingSyncIfDue(allowApiFailure: true);
    return _sessionFromFirebaseUser(refreshed);
  }

  Future<AuthSession> signInWithGoogle() async {
    _requireReady();
    if (!_firebaseConfig.isGoogleSignInConfigured) {
      throw AppAuthException(
        'Add GOOGLE_WEB_CLIENT_ID at build time for Google Sign-In.',
      );
    }
    try {
      final google = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: _firebaseConfig.webClientId,
        clientId: _firebaseConfig.nativeGoogleClientId,
      );
      final account = await google.signIn();
      if (account == null) {
        throw AppAuthException('Google sign-in was cancelled.',
            code: 'cancelled');
      }
      final tokens = await account.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      );
      final firebaseCredential =
          await _firebaseAuth!.signInWithCredential(credential);
      final user = firebaseCredential.user;
      if (user == null) {
        throw AppAuthException('Firebase did not return a user.');
      }
      await _syncSignedInUser(user, allowApiFailure: true);
      await pushReadingSyncIfDue(
        minInterval: Duration.zero,
        allowApiFailure: true,
      );
      return _sessionFromFirebaseUser(
        user,
        createdNewAccount:
            firebaseCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on AppAuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      throw AppAuthException(_firebaseMessage(e), code: e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn(
        serverClientId: _firebaseConfig.webClientId,
        clientId: _firebaseConfig.nativeGoogleClientId,
      ).signOut();
    } catch (_) {}
    if (_firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
    await _readRepository.clearAuthLink();
  }

  Future<HunnyApiMe> fetchApiMe() async {
    final token = await _firebaseIdToken();
    final res = await _authedDio(token).get<dynamic>('/api/v1/me');
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw HunnyApiException('GET /api/v1/me failed', statusCode: code);
    }
    return HunnyApiMe.fromJson(data);
  }

  Future<void> syncRemoteUser() async {
    final token = await _firebaseIdToken();
    final res = await _authedDio(token).post<dynamic>(
      '/api/v1/auth/sync',
      data: <String, dynamic>{},
      options: Options(contentType: Headers.jsonContentType),
    );
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw HunnyApiException('POST /api/v1/auth/sync failed',
          statusCode: code);
    }
  }

  Future<HunnySyncPushResult> pushReadingSync() async {
    final token = await _firebaseIdToken();
    final payload = await _readRepository.exportReadingBackupSnapshot();
    final res = await _authedDio(token).post<dynamic>(
      '/api/v1/sync/push',
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw HunnyApiException(
        _apiFailureMessage(
          'POST /api/v1/sync/push failed',
          data,
        ),
        statusCode: code,
      );
    }
    final result = HunnySyncPushResult.fromJson(data);
    await _readRepository.applyReadingSyncPushResult(result);
    return result;
  }

  Future<HunnySyncBootstrapResult> bootstrapReadingSync() async {
    final token = await _firebaseIdToken();
    final res = await _authedDio(token).get<dynamic>(
      '/api/v1/sync/bootstrap',
    );
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw HunnyApiException('GET /api/v1/sync/bootstrap failed',
          statusCode: code);
    }
    final result = HunnySyncBootstrapResult.fromJson(data);
    await _readRepository.applyReadingSyncBootstrap(result);
    return result;
  }

  Future<HunnySyncPushResult?> pushReadingSyncIfDue({
    Duration minInterval = const Duration(minutes: 15),
    bool allowApiFailure = true,
  }) async {
    if (!_apiConfig.isConfigured || !isAvailable) return null;
    final lastSyncedAt = await _readRepository.getLastReadingSyncAt();
    if (lastSyncedAt != null &&
        minInterval > Duration.zero &&
        DateTime.now().difference(lastSyncedAt.toLocal()) < minInterval) {
      return null;
    }
    try {
      return await pushReadingSync();
    } catch (_) {
      if (!allowApiFailure) rethrow;
      return null;
    }
  }

  Future<void> _syncSignedInUser(
    fb.User user, {
    bool allowApiFailure = false,
  }) async {
    await _readRepository.syncAuthUserId(user.uid);
    if (!_apiConfig.isConfigured) return;
    try {
      await syncRemoteUser();
    } catch (_) {
      if (!allowApiFailure) rethrow;
    }
  }

  Dio _authedDio(String token) {
    if (!_apiConfig.isConfigured) {
      throw HunnyApiException('HUNNY_API_BASE_URL is not set');
    }
    return Dio(
      BaseOptions(
        baseUrl: _apiConfig.baseUrl,
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        validateStatus: (code) => code != null && code < 600,
      ),
    );
  }

  String _apiFailureMessage(String fallback, Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return '$fallback: $error';
      }
    }
    return fallback;
  }

  Future<String> _firebaseIdToken() async {
    _requireReady();
    final user = _firebaseAuth!.currentUser;
    if (user == null) {
      throw HunnyApiException('No Firebase user — sign in again');
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw HunnyApiException('Firebase did not return an ID token');
    }
    return token;
  }

  void _requireReady() {
    if (!isAvailable) {
      throw AppAuthException(
        'Firebase Auth is not configured. Add Firebase dart-defines and initialize Firebase.',
      );
    }
  }

  AuthSession _sessionFromFirebaseUser(
    fb.User user, {
    bool createdNewAccount = false,
  }) {
    return AuthSession(
      createdNewAccount: createdNewAccount,
      user: AuthUser(
        id: user.uid,
        email: user.email,
        name: user.displayName,
        photoUrl: user.photoURL,
      ),
    );
  }

  String _firebaseMessage(fb.FirebaseAuthException e) {
    return e.message ?? 'Firebase Auth failed (${e.code})';
  }
}

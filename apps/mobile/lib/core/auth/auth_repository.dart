import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../api/hunny_api_client.dart';
import '../api/hunny_api_config.dart';
import '../api/hunny_api_models.dart';
import '../../features/read/data/read_repository.dart';
import 'auth_models.dart';
import 'supabase_auth_config.dart';

/// Supabase Auth session + local profile link.
///
/// The server database lives behind Next.js API routes. Supabase owns
/// authentication; `local_users.auth_user_id` stores the Supabase user UUID.
class AuthRepository {
  AuthRepository({
    required SupabaseAuthConfig supabaseConfig,
    required bool supabaseReady,
    required ReadRepository readRepository,
    SupabaseClient? supabaseClient,
    HunnyApiConfig? apiConfig,
    HunnyApiReachability? apiReachability,
  })  : _supabaseConfig = supabaseConfig,
        _supabaseReady = supabaseReady,
        _supabase = supabaseReady
            ? (supabaseClient ?? Supabase.instance.client)
            : null,
        _readRepository = readRepository,
        _apiConfig = apiConfig ?? HunnyApiConfig.fromEnvironment(),
        _apiReachability = apiReachability ??
            HunnyApiReachability(
              config: apiConfig ?? HunnyApiConfig.fromEnvironment(),
            );

  final SupabaseAuthConfig _supabaseConfig;
  final bool _supabaseReady;
  final SupabaseClient? _supabase;
  final ReadRepository _readRepository;
  final HunnyApiConfig _apiConfig;
  final HunnyApiReachability _apiReachability;

  bool get isAvailable => _supabaseReady && _supabase != null;

  bool get isApiConfigured => _apiConfig.isConfigured;

  bool get isGoogleSignInConfigured => _supabaseConfig.isGoogleSignInConfigured;

  Future<AuthSession?> refreshRemoteSession() async {
    final client = _supabase;
    if (!_supabaseReady || client == null) return null;

    var session = client.auth.currentSession;
    if (session == null) {
      await _readRepository.clearAuthLink();
      return null;
    }

    try {
      final refreshed = await client.auth.refreshSession();
      session = refreshed.session ?? session;
    } catch (_) {
      // Keep existing session when refresh fails offline.
    }

    final user = session?.user;
    if (user == null) {
      await _readRepository.clearAuthLink();
      return null;
    }

    await _syncSignedInUser(user, allowApiFailure: true);
    await pushReadingSyncIfDue(allowApiFailure: true);
    return _sessionFromUser(user);
  }

  Future<AuthSession> signInWithGoogle() async {
    _requireReady();
    if (!_supabaseConfig.isGoogleSignInConfigured) {
      throw AppAuthException(
        'Add GOOGLE_WEB_CLIENT_ID at build time for Google Sign-In.',
      );
    }
    try {
      final google = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: _supabaseConfig.webClientId,
        clientId: _supabaseConfig.nativeGoogleClientId,
      );
      final account = await google.signIn();
      if (account == null) {
        throw AppAuthException('Google sign-in was cancelled.',
            code: 'cancelled');
      }
      final tokens = await account.authentication;
      final idToken = tokens.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw AppAuthException('Google did not return an ID token.');
      }

      final response = await _supabase!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: tokens.accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw AppAuthException('Supabase did not return a user.');
      }

      final createdAt = DateTime.tryParse(user.createdAt);
      final createdNewAccount = createdAt != null &&
          DateTime.now().difference(createdAt.toUtc()).inMinutes < 2;

      await _syncSignedInUser(user, allowApiFailure: true);
      await pushReadingSyncIfDue(
        minInterval: Duration.zero,
        allowApiFailure: true,
      );
      return _sessionFromUser(user, createdNewAccount: createdNewAccount);
    } on AppAuthException {
      rethrow;
    } on AuthException catch (e) {
      throw AppAuthException(_supabaseMessage(e), code: e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn(
        serverClientId: _supabaseConfig.webClientId,
        clientId: _supabaseConfig.nativeGoogleClientId,
      ).signOut();
    } catch (_) {}
    if (_supabase != null) {
      await _supabase.auth.signOut();
    }
    await _readRepository.clearAuthLink();
  }

  Future<HunnyApiMe> fetchApiMe() async {
    if (!await _apiReachability.canReachApi()) {
      throw HunnyApiException('Hunny API is offline');
    }
    final token = await _accessToken();
    final res = await _authedDio(token).get<dynamic>('/api/v1/me');
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw HunnyApiException('GET /api/v1/me failed', statusCode: code);
    }
    return HunnyApiMe.fromJson(data);
  }

  Future<void> syncRemoteUser() async {
    if (!await _apiReachability.canReachApi()) {
      throw HunnyApiException('Hunny API is offline');
    }
    final token = await _accessToken();
    final res = await _authedDio(token).post<dynamic>(
      '/api/v1/auth/sync',
      data: <String, dynamic>{},
      options: Options(contentType: 'application/json'),
    );
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw HunnyApiException('POST /api/v1/auth/sync failed',
          statusCode: code);
    }
  }

  Future<HunnySyncPushResult> pushReadingSync() async {
    if (!await _apiReachability.canReachApi()) {
      throw HunnyApiException('Hunny API is offline');
    }
    final token = await _accessToken();
    final payload = await _readRepository.exportReadingBackupSnapshot();
    final res = await _authedDio(token).post<dynamic>(
      '/api/v1/sync/push',
      data: payload,
      options: Options(contentType: 'application/json'),
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
    if (!await _apiReachability.canReachApi()) {
      throw HunnyApiException('Hunny API is offline');
    }
    final token = await _accessToken();
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
    if (!await _apiReachability.canReachApi()) return null;
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
    User user, {
    bool allowApiFailure = false,
  }) async {
    await _readRepository.syncAuthUserId(user.id);
    if (!_apiConfig.isConfigured) return;
    if (!await _apiReachability.canReachApi()) return;
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
    return HunnyApiClient.create(
      _apiConfig,
      headers: <String, dynamic>{
        'Authorization': 'Bearer $token',
      },
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

  Future<String> _accessToken() async {
    _requireReady();
    final session = _supabase!.auth.currentSession;
    if (session == null) {
      throw HunnyApiException('No Supabase session — sign in again');
    }
    final token = session.accessToken;
    if (token.isEmpty) {
      throw HunnyApiException('Supabase did not return an access token');
    }
    return token;
  }

  void _requireReady() {
    if (!isAvailable) {
      throw AppAuthException(
        'Supabase Auth is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
      );
    }
  }

  AuthSession _sessionFromUser(
    User user, {
    bool createdNewAccount = false,
  }) {
    final meta = user.userMetadata ?? {};
    final name = meta['full_name'] ?? meta['name'];
    final photo = meta['avatar_url'] ?? meta['picture'];
    return AuthSession(
      createdNewAccount: createdNewAccount,
      user: AuthUser(
        id: user.id,
        email: user.email,
        name: name is String ? name : null,
        photoUrl: photo is String ? photo : null,
      ),
    );
  }

  String _supabaseMessage(AuthException e) {
    return e.message;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/hunny_api_config.dart';
import '../api/hunny_api_models.dart';
import '../../features/read/data/read_repository.dart';
import 'neon_auth_api.dart';
import 'neon_auth_models.dart';

/// Phase F: Neon Auth session + link `local_users.auth_user_id` (guest merge).
/// Stores a Neon-issued API JWT (`GET …/token`) for `Authorization: Bearer` to Hunny API.
class AuthRepository {
  AuthRepository({
    required NeonAuthApi neonAuthApi,
    required ReadRepository readRepository,
    FlutterSecureStorage? jwtStorage,
    HunnyApiConfig? apiConfig,
  })  : _api = neonAuthApi,
        _readRepository = readRepository,
        _jwtStorage = jwtStorage ?? const FlutterSecureStorage(),
        _apiConfig = apiConfig ?? HunnyApiConfig.fromEnvironment();

  static const _jwtKey = 'neon_auth_api_jwt';

  final NeonAuthApi _api;
  final ReadRepository _readRepository;
  final FlutterSecureStorage _jwtStorage;
  final HunnyApiConfig _apiConfig;

  bool get isAvailable => _api.isReady;

  bool get isApiConfigured => _apiConfig.isConfigured;

  /// Pulls remote session (cookies) and aligns `local_users` when logged in.
  Future<NeonAuthSession?> refreshRemoteSession() async {
    if (!_api.isReady) return null;
    try {
      final session = await _api.getSession();
      if (session != null) {
        await _readRepository.syncNeonAuthUserId(session.user.id);
        await _persistApiJwt(session);
      } else {
        await _eraseApiJwt();
      }
      return session;
    } on FormatException {
      await _eraseApiJwt();
      return null;
    }
  }

  Future<NeonAuthSession> signInEmail({
    required String email,
    required String password,
  }) async {
    final session = await _api.signInEmail(email: email, password: password);
    await _readRepository.syncNeonAuthUserId(session.user.id);
    await _persistApiJwt(session);
    return session;
  }

  Future<NeonAuthSession> signUpEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await _api.signUpEmail(
      name: name,
      email: email,
      password: password,
    );
    await _readRepository.syncNeonAuthUserId(session.user.id);
    await _persistApiJwt(session);
    return session;
  }

  Future<void> signOut() async {
    await _eraseApiJwt();
    await _api.signOut();
    await _readRepository.clearNeonAuthLink();
  }

  /// Verifies the stored Neon JWT against Hunny API (`GET /api/v1/me`).
  Future<HunnyApiMe> fetchApiMe() async {
    if (!_apiConfig.isConfigured) {
      throw HunnyApiException('HUNNY_API_BASE_URL is not set');
    }
    final jwt = await _jwtStorage.read(key: _jwtKey);
    if (jwt == null || jwt.isEmpty) {
      throw HunnyApiException('No API JWT — sign in again');
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: _apiConfig.baseUrl,
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        validateStatus: (code) => code != null && code < 600,
      ),
    );
    final res = await dio.get<dynamic>('/api/v1/me');
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw HunnyApiException(
        'GET /api/v1/me failed',
        statusCode: code,
      );
    }
    return HunnyApiMe.fromJson(data);
  }

  Future<void> _persistApiJwt(NeonAuthSession session) async {
    final fromSession = session.apiJwt;
    if (fromSession != null && fromSession.isNotEmpty) {
      await _jwtStorage.write(key: _jwtKey, value: fromSession);
      return;
    }
    final fetched = await _api.fetchApiJwt();
    if (fetched != null && fetched.isNotEmpty) {
      await _jwtStorage.write(key: _jwtKey, value: fetched);
    }
  }

  Future<void> _eraseApiJwt() async {
    await _jwtStorage.delete(key: _jwtKey);
  }
}

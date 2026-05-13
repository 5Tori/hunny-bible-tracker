import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'neon_auth_config.dart';
import 'neon_auth_models.dart';

/// Better Auth–compatible HTTP client for Neon Auth (session cookies).
class NeonAuthApi {
  NeonAuthApi({required NeonAuthConfig config}) : _config = config;

  final NeonAuthConfig _config;
  Dio? _dio;
  PersistCookieJar? _jar;

  bool get isReady => _dio != null;

  Future<void> initIfConfigured() async {
    if (!_config.isConfigured) return;
    if (_dio != null) return;

    final dir = await getApplicationSupportDirectory();
    final jar = PersistCookieJar(
      storage: FileStorage(p.join(dir.path, 'neon_auth_cookies')),
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        headers: <String, dynamic>{
          'Origin': _config.trustedOrigin,
          'Accept': 'application/json',
        },
        validateStatus: (code) => code != null && code < 600,
      ),
    );
    dio.interceptors.add(CookieManager(jar));

    _jar = jar;
    _dio = dio;
  }

  Future<NeonAuthSession> signInEmail({
    required String email,
    required String password,
  }) async {
    await _requireReady();
    final res = await _dio!.post<dynamic>(
      '/sign-in/email',
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    return _parseAuthResponse(res);
  }

  Future<NeonAuthSession> signUpEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await _requireReady();
    final res = await _dio!.post<dynamic>(
      '/sign-up/email',
      data: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    return _parseAuthResponse(res);
  }

  Future<NeonAuthSession?> getSession() async {
    await _requireReady();
    final res = await _dio!.get<dynamic>(
      '/get-session',
      options: Options(responseType: ResponseType.json),
    );
    final data = res.data;
    if (data == null) return null;
    if (data is! Map<String, dynamic>) return null;
    if (data['user'] == null) return null;
    final jwt = res.headers.value('set-auth-jwt');
    return NeonAuthSession.fromGetSessionJson(data, apiJwt: jwt);
  }

  /// Session-scoped JWT for backends that verify with Neon JWKS (`GET /token`).
  Future<String?> fetchApiJwt() async {
    await _requireReady();
    final res = await _dio!.get<dynamic>(
      '/token',
      options: Options(responseType: ResponseType.json),
    );
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code >= 200 && code < 300 && data is Map<String, dynamic>) {
      final t = data['token'] as String?;
      if (t != null && t.isNotEmpty) return t;
    }
    return null;
  }

  Future<void> signOut() async {
    if (_dio != null) {
      try {
        await _dio!.post<dynamic>(
          '/sign-out',
          data: <String, dynamic>{},
          options: Options(contentType: Headers.jsonContentType),
        );
      } catch (_) {
        // Some Neon Auth builds reject Origin on sign-out; still drop cookies.
      }
    }
    await _jar?.deleteAll();
  }

  Future<void> _requireReady() async {
    if (_dio == null) {
      throw NeonAuthException(
        'Neon Auth is not configured (empty NEON_AUTH_BASE_URL).',
      );
    }
  }

  NeonAuthSession _parseAuthResponse(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    final data = res.data;
    if (code >= 200 && code < 300 && data is Map<String, dynamic>) {
      if (data['user'] != null) {
        return NeonAuthSession.fromSignJson(data);
      }
    }
    if (data is Map<String, dynamic>) {
      final msg = data['message'] as String? ?? 'Request failed';
      final c = data['code'] as String?;
      throw NeonAuthException(msg, code: c);
    }
    throw NeonAuthException('Unexpected response ($code)');
  }
}

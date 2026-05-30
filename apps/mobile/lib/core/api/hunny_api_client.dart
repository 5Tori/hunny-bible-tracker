import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'hunny_api_config.dart';
import 'hunny_api_models.dart';

class HunnyApiClient {
  HunnyApiClient._();

  static const requestConnectTimeout = Duration(seconds: 8);
  static const requestReceiveTimeout = Duration(seconds: 20);
  static const probeConnectTimeout = Duration(seconds: 4);
  static const probeReceiveTimeout = Duration(seconds: 6);

  static Dio create(
    HunnyApiConfig config, {
    Map<String, dynamic>? headers,
    Duration connectTimeout = requestConnectTimeout,
    Duration receiveTimeout = requestReceiveTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: receiveTimeout,
        headers: <String, dynamic>{
          'Accept': 'application/json',
          ...?headers,
        },
        validateStatus: (code) => code != null && code < 600,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(_RequestPerfInterceptor());
    }

    return dio;
  }
}

class _RequestPerfInterceptor extends Interceptor {
  static const _extraStartedAtKey = 'hunny_api_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_extraStartedAtKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, error: err.type.name);
    handler.next(err);
  }

  void _log(
    RequestOptions options,
    int? statusCode, {
    String? error,
  }) {
    final startedAt = options.extra[_extraStartedAtKey];
    final durationMs = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : null;
    final path = options.uri.path;
    final method = options.method;
    final statusLabel = statusCode?.toString() ?? 'ERR';
    final suffix = error == null ? '' : ' error=$error';

    debugPrint(
      '[HunnyApi] $method $path $statusLabel '
      '${durationMs ?? '?'}ms '
      'connect=${options.connectTimeout?.inMilliseconds}ms '
      'receive=${options.receiveTimeout?.inMilliseconds}ms$suffix',
    );
  }
}

class HunnyApiReachability {
  HunnyApiReachability({
    HunnyApiConfig? config,
  }) : _config = config ?? HunnyApiConfig.fromEnvironment();

  static const _onlineTtl = Duration(seconds: 30);
  static const _offlineCooldown = Duration(seconds: 20);
  static final Map<String, _ReachabilitySnapshot> _snapshots = {};
  static final Map<String, Future<bool>> _inFlight = {};

  final HunnyApiConfig _config;

  bool get isConfigured => _config.isConfigured;

  Future<bool> canReachApi({bool force = false}) async {
    if (!_config.isConfigured) return false;

    final baseUrl = _config.baseUrl;
    final snapshot = _snapshots[baseUrl];
    if (!force && snapshot != null) {
      final age = DateTime.now().difference(snapshot.checkedAt);
      if (snapshot.reachable && age < _onlineTtl) return true;
      if (!snapshot.reachable && age < _offlineCooldown) return false;
    }

    final existing = _inFlight[baseUrl];
    if (existing != null) return existing;

    final probe = _probe(baseUrl);
    _inFlight[baseUrl] = probe;
    try {
      return await probe;
    } finally {
      _inFlight.remove(baseUrl);
    }
  }

  void markSuccess() {
    if (!_config.isConfigured) return;
    _snapshots[_config.baseUrl] = _ReachabilitySnapshot(
      reachable: true,
      checkedAt: DateTime.now(),
    );
  }

  void markFailure(Object error) {
    if (!_config.isConfigured) return;
    if (error is DioException &&
        error.response != null &&
        (error.response!.statusCode ?? 0) < 500) {
      markSuccess();
      return;
    }
    final statusCode = switch (error) {
      HunnyApiException(:final statusCode) => statusCode,
      _ => null,
    };
    if (statusCode != null && statusCode > 0 && statusCode < 500) {
      markSuccess();
      return;
    }
    _snapshots[_config.baseUrl] = _ReachabilitySnapshot(
      reachable: false,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _probe(String baseUrl) async {
    final config = HunnyApiConfig.fromBaseUrl(baseUrl);
    final dio = HunnyApiClient.create(
      config,
      connectTimeout: HunnyApiClient.probeConnectTimeout,
      receiveTimeout: HunnyApiClient.probeReceiveTimeout,
    );

    // Auth/sync routes respond quickly (401 without token). /api/health runs a
    // DB query and can hang when Hyperdrive is slow even though sync works.
    final bootstrap = await _probeRequest(
      dio.get<dynamic>('/api/v1/sync/bootstrap'),
    );
    if (bootstrap != null) {
      _snapshots[baseUrl] = _ReachabilitySnapshot(
        reachable: bootstrap,
        checkedAt: DateTime.now(),
      );
      return bootstrap;
    }

    final health = await _probeRequest(dio.get<dynamic>('/api/health'));
    final reachable = health ?? false;
    _snapshots[baseUrl] = _ReachabilitySnapshot(
      reachable: reachable,
      checkedAt: DateTime.now(),
    );
    return reachable;
  }

  Future<bool?> _probeRequest(Future<Response<dynamic>> request) async {
    try {
      final response = await request;
      return _isReachableStatus(response.statusCode ?? 0);
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code > 0) return _isReachableStatus(code);
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isReachableStatus(int code) {
    if (code == 401) return true;
    return code >= 200 && code < 500;
  }
}

class _ReachabilitySnapshot {
  const _ReachabilitySnapshot({
    required this.reachable,
    required this.checkedAt,
  });

  final bool reachable;
  final DateTime checkedAt;
}

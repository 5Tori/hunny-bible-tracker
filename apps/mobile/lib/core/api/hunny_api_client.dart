import 'package:dio/dio.dart';

import 'hunny_api_config.dart';

class HunnyApiClient {
  HunnyApiClient._();

  static const requestConnectTimeout = Duration(milliseconds: 1200);
  static const requestReceiveTimeout = Duration(milliseconds: 2500);
  static const probeConnectTimeout = Duration(milliseconds: 1500);
  static const probeReceiveTimeout = Duration(milliseconds: 2000);

  static Dio create(
    HunnyApiConfig config, {
    Map<String, dynamic>? headers,
    Duration connectTimeout = requestConnectTimeout,
    Duration receiveTimeout = requestReceiveTimeout,
  }) {
    return Dio(
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
    _snapshots[_config.baseUrl] = _ReachabilitySnapshot(
      reachable: false,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _probe(String baseUrl) async {
    try {
      final config = HunnyApiConfig.fromBaseUrl(baseUrl);
      final dio = HunnyApiClient.create(
        config,
        connectTimeout: HunnyApiClient.probeConnectTimeout,
        receiveTimeout: HunnyApiClient.probeReceiveTimeout,
      );
      final response = await dio.get<dynamic>('/api/health');
      final code = response.statusCode ?? 0;
      final reachable = code >= 200 && code < 500;
      _snapshots[baseUrl] = _ReachabilitySnapshot(
        reachable: reachable,
        checkedAt: DateTime.now(),
      );
      return reachable;
    } catch (_) {
      _snapshots[baseUrl] = _ReachabilitySnapshot(
        reachable: false,
        checkedAt: DateTime.now(),
      );
      return false;
    }
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

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_auth_config.dart';
import 'supabase_read_exception.dart';

class HunnySupabaseClient {
  HunnySupabaseClient({
    SupabaseAuthConfig? config,
    SupabaseClient? client,
  })  : _config = config ?? SupabaseAuthConfig.fromEnvironment(),
        _client = client;

  final SupabaseAuthConfig _config;
  final SupabaseClient? _client;

  bool get isConfigured => _config.isConfigured;

  SupabaseClient get _supabase {
    final client = _client;
    if (client != null) return client;
    if (!_config.isConfigured) {
      throw SupabaseReadException('Supabase is not configured for this build.');
    }
    return Supabase.instance.client;
  }

  Future<dynamic> rpc(
    String fn, {
    Map<String, dynamic>? params,
  }) async {
    if (!_config.isConfigured) {
      throw SupabaseReadException('Supabase is not configured for this build.');
    }

    final startedAt = DateTime.now();
    try {
      final result = await _supabase.rpc(fn, params: params);
      if (kDebugMode) {
        final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('[HunnySupabase] rpc $fn ${durationMs}ms');
      }
      return result;
    } catch (error, stack) {
      if (kDebugMode) {
        final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('[HunnySupabase] rpc $fn ERR ${durationMs}ms $error');
        debugPrint('$stack');
      }
      throw SupabaseReadException(
        'Supabase RPC $fn failed.',
        cause: error,
      );
    }
  }

  Future<bool> canReachSupabase({bool force = false}) async {
    if (!_config.isConfigured) return false;
    try {
      await rpc(
        'mobile_today_message_latest',
        params: {'p_language': 'en'},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

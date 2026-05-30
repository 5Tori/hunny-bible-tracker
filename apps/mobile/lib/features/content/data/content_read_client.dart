import '../../../core/supabase/hunny_supabase_client.dart';
import '../../../core/supabase/remote_read_mode.dart';
import 'content_api_client.dart';
import 'content_supabase_client.dart';

class ContentReadClient {
  ContentReadClient({
    RemoteReadMode? mode,
    ContentApiClient? apiClient,
    ContentSupabaseClient? supabaseClient,
    HunnySupabaseClient? reachabilityClient,
    bool fallbackToApi = true,
  })  : _mode = mode ?? RemoteReadMode.fromEnvironment(),
        _apiClient = apiClient ?? ContentApiClient(),
        _supabaseClient = supabaseClient ?? ContentSupabaseClient(),
        _reachabilityClient = reachabilityClient ?? HunnySupabaseClient(),
        _fallbackToApi = fallbackToApi;

  final RemoteReadMode _mode;
  final ContentApiClient _apiClient;
  final ContentSupabaseClient _supabaseClient;
  final HunnySupabaseClient _reachabilityClient;
  final bool _fallbackToApi;

  bool get isConfigured =>
      _mode.prefersSupabaseRpc
          ? _supabaseClient.isConfigured
          : _apiClient.isConfigured;

  Future<bool> canReachRemote({bool force = false}) {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      return _reachabilityClient.canReachSupabase(force: force);
    }
    return _apiClient.canReachApi(force: force);
  }

  Future<List<RemoteContent>> fetchPublishedContent({
    String sort = 'featured',
    String language = 'en',
    String? contentType,
    String? tag,
    int? limit,
    bool skipReachabilityCheck = false,
  }) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      if (!skipReachabilityCheck &&
          !await _reachabilityClient.canReachSupabase()) {
        return const [];
      }
      try {
        return await _supabaseClient.fetchPublishedContent(
          sort: sort,
          language: language,
          contentType: contentType,
          tag: tag,
          limit: limit,
        );
      } catch (_) {
        if (!_fallbackToApi) rethrow;
      }
    }

    return _apiClient.fetchPublishedContent(
      sort: sort,
      language: language,
      contentType: contentType,
      tag: tag,
      limit: limit,
      skipReachabilityCheck: skipReachabilityCheck,
    );
  }

  Future<RemoteContent?> fetchContentByIdentifier(
    String identifier, {
    String language = 'en',
  }) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      try {
        return await _supabaseClient.fetchContentByIdentifier(
          identifier,
          language: language,
        );
      } catch (_) {
        if (!_fallbackToApi) rethrow;
      }
    }

    return _apiClient.fetchContentByIdentifier(
      identifier,
      language: language,
    );
  }
}

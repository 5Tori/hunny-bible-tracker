import '../../../core/supabase/remote_read_mode.dart';
import 'today_message_api_client.dart';
import 'today_message_supabase_client.dart';

class TodayMessageReadClient {
  TodayMessageReadClient({
    RemoteReadMode? mode,
    TodayMessageApiClient? apiClient,
    TodayMessageSupabaseClient? supabaseClient,
    bool fallbackToApi = true,
  })  : _mode = mode ?? RemoteReadMode.fromEnvironment(),
        _apiClient = apiClient ?? TodayMessageApiClient(),
        _supabaseClient = supabaseClient ?? TodayMessageSupabaseClient(),
        _fallbackToApi = fallbackToApi;

  final RemoteReadMode _mode;
  final TodayMessageApiClient _apiClient;
  final TodayMessageSupabaseClient _supabaseClient;
  final bool _fallbackToApi;

  TodayMessageApiClient get apiClient => _apiClient;

  bool get isConfigured =>
      _mode.prefersSupabaseRpc
          ? _supabaseClient.isConfigured
          : _apiClient.isConfigured;

  Future<TodayMessage?> fetchTodayMessage({
    required String date,
    String language = 'en',
  }) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      try {
        return await _supabaseClient.fetchTodayMessage(
          date: date,
          language: language,
        );
      } catch (_) {
        if (!_fallbackToApi) rethrow;
      }
    }

    return _apiClient.fetchTodayMessage(
      date: date,
      language: language,
    );
  }

  Future<TodayMessageEngagement> heartTodayMessage(String id) =>
      _apiClient.heartTodayMessage(id);

  Future<TodayMessageEngagement> shareTodayMessage(String id) =>
      _apiClient.shareTodayMessage(id);
}

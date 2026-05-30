import '../../../core/api/hunny_api_config.dart';
import '../../../core/supabase/hunny_supabase_client.dart';
import 'today_message_api_client.dart';

class TodayMessageSupabaseClient {
  TodayMessageSupabaseClient({
    HunnySupabaseClient? supabaseClient,
    HunnyApiConfig? apiConfig,
  })  : _supabaseClient = supabaseClient ?? HunnySupabaseClient(),
        _apiConfig = apiConfig ?? HunnyApiConfig.fromEnvironment();

  final HunnySupabaseClient _supabaseClient;
  final HunnyApiConfig _apiConfig;

  bool get isConfigured => _supabaseClient.isConfigured;

  Future<TodayMessage?> fetchTodayMessage({
    required String date,
    String language = 'en',
  }) async {
    final payload = await _supabaseClient.rpc(
      'mobile_today_message_latest',
      params: {
        'p_language': language,
        'p_date': date,
      },
    );
    if (payload == null) return null;
    if (payload is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid mobile_today_message_latest response',
      );
    }

    final shareUrl = _nullableString(payload['share_url']) ??
        _buildShareUrl(_requiredString(payload, 'publish_date'));
    return TodayMessage.fromJson({
      ...payload,
      'share_url': shareUrl,
    });
  }

  String? _buildShareUrl(String publishDate) {
    if (!_apiConfig.isConfigured) return null;
    return '${_apiConfig.baseUrl}/today-message/$publishDate';
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _nullableString(json[key]);
  if (value == null) {
    throw FormatException('Missing required string: $key');
  }
  return value;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

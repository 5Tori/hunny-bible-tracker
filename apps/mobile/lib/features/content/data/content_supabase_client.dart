import '../../../core/supabase/hunny_supabase_client.dart';
import 'content_api_client.dart';

class ContentSupabaseClient {
  ContentSupabaseClient({
    HunnySupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient ?? HunnySupabaseClient();

  final HunnySupabaseClient _supabaseClient;

  bool get isConfigured => _supabaseClient.isConfigured;

  Future<List<RemoteContent>> fetchPublishedContent({
    String sort = 'featured',
    String language = 'en',
    String? contentType,
    String? tag,
    int? limit,
  }) async {
    final payload = await _supabaseClient.rpc(
      'mobile_content_list',
      params: {
        'p_language': language,
        'p_sort': sort,
        if (contentType != null && contentType.trim().isNotEmpty)
          'p_type': contentType,
        if (tag != null && tag.trim().isNotEmpty) 'p_tag': tag,
        if (limit != null) 'p_limit': limit,
      },
    );

    if (payload == null) return const [];
    if (payload is! List) {
      throw const FormatException('Invalid mobile_content_list response');
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(RemoteContent.fromJson)
        .toList();
  }

  Future<RemoteContent?> fetchContentByIdentifier(
    String identifier, {
    String language = 'en',
  }) async {
    final payload = await _supabaseClient.rpc(
      'mobile_content_detail',
      params: {
        'p_identifier': identifier,
        'p_language': language,
      },
    );
    if (payload == null) return null;
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid mobile_content_detail response');
    }
    return RemoteContent.fromJson(payload);
  }
}

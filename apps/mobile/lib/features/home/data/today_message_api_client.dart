import 'package:dio/dio.dart';

import '../../../core/api/hunny_api_config.dart';

class TodayMessageApiClient {
  TodayMessageApiClient({HunnyApiConfig? config})
      : _config = config ?? HunnyApiConfig.fromEnvironment();

  final HunnyApiConfig _config;

  bool get isConfigured => _config.isConfigured;

  Future<TodayMessage?> fetchTodayMessage({
    required String date,
    String language = 'en',
  }) async {
    if (!_config.isConfigured) return null;

    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        headers: const {'Accept': 'application/json'},
        validateStatus: (code) => code != null && code < 600,
      ),
    );
    final response = await dio.get<dynamic>(
      '/api/v1/today-message',
      queryParameters: {
        'date': date,
        'language': language,
      },
    );
    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw StateError('GET /api/v1/today-message failed with status $code');
    }

    final message = data['message'];
    if (message == null) return null;
    if (message is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid message in /api/v1/today-message response',
      );
    }
    return TodayMessage.fromJson(message);
  }
}

class TodayMessage {
  const TodayMessage({
    required this.id,
    required this.publishDate,
    required this.language,
    required this.verseReference,
    required this.verseText,
    required this.message,
    required this.imageUrl,
  });

  final String id;
  final String publishDate;
  final String language;
  final String verseReference;
  final String? verseText;
  final String? message;
  final String? imageUrl;

  String get primaryText => verseText ?? message ?? verseReference;

  factory TodayMessage.fromJson(Map<String, dynamic> json) {
    return TodayMessage(
      id: _requiredString(json, 'id'),
      publishDate: _requiredString(json, 'publish_date'),
      language: _stringValue(json['language'], fallback: 'en'),
      verseReference: _requiredString(json, 'verse_reference'),
      verseText: _nullableString(json['verse_text']),
      message: _nullableString(json['message']),
      imageUrl: _nullableString(json['image_url']),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _nullableString(json[key]);
  if (value == null) {
    throw FormatException('Missing required string: $key');
  }
  return value;
}

String _stringValue(Object? value, {String fallback = ''}) {
  return _nullableString(value) ?? fallback;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}

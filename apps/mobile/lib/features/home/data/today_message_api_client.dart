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

  Future<TodayMessageEngagement> heartTodayMessage(String id) {
    return _incrementEngagement(id: id, action: 'heart');
  }

  Future<TodayMessageEngagement> shareTodayMessage(String id) {
    return _incrementEngagement(id: id, action: 'share');
  }

  Future<TodayMessageEngagement> _incrementEngagement({
    required String id,
    required String action,
  }) async {
    if (!_config.isConfigured) {
      throw StateError('HUNNY_API_BASE_URL is not set');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        headers: const {'Accept': 'application/json'},
        validateStatus: (code) => code != null && code < 600,
      ),
    );
    final response = await dio.post<dynamic>(
      '/api/v1/today-message/$id/$action',
      data: const <String, dynamic>{},
      options: Options(contentType: Headers.jsonContentType),
    );
    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw StateError(
        'POST /api/v1/today-message/$id/$action failed with status $code',
      );
    }
    final message = data['message'];
    if (message is! Map<String, dynamic>) {
      throw const FormatException('Invalid engagement response');
    }
    return TodayMessageEngagement.fromJson(message);
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
    required this.shareUrl,
    required this.hintTitle,
    required this.hintSummary,
    required this.articleTitle,
    required this.articleBody,
    required this.relatedPlanTemplateKey,
    required this.relatedPlanTitle,
    required this.relatedPlanChapters,
    required this.relatedPlanMinutes,
    required this.heartCount,
    required this.shareCount,
  });

  final String id;
  final String publishDate;
  final String language;
  final String verseReference;
  final String? verseText;
  final String? message;
  final String? imageUrl;
  final String? shareUrl;
  final String? hintTitle;
  final String? hintSummary;
  final String? articleTitle;
  final String? articleBody;
  final String? relatedPlanTemplateKey;
  final String? relatedPlanTitle;
  final int? relatedPlanChapters;
  final int? relatedPlanMinutes;
  final int heartCount;
  final int shareCount;

  String get primaryText => verseText ?? message ?? verseReference;

  String get reflectionTitle => hintTitle ?? 'A quick reflection';

  String get reflectionSummary =>
      hintSummary ??
      message ??
      'This verse invites a slower look at how God works through ordinary days.';

  String get articleHeading => articleTitle ?? reflectionTitle;

  String get articleText => articleBody ?? reflectionSummary;

  bool get hasRelatedPlan =>
      relatedPlanTemplateKey != null && relatedPlanTitle != null;

  String? get planTemplateKey => relatedPlanTemplateKey;

  String get planTitle => relatedPlanTitle ?? 'Related plan';

  int get planChapters => relatedPlanChapters ?? 0;

  int get planMinutes => relatedPlanMinutes ?? 0;

  String get shareTitle => '$verseReference | Hunny Bible Tracker';

  String get shareText {
    final parts = [
      primaryText,
      verseReference,
      if (shareUrl != null) shareUrl!,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join('\n\n');
  }

  TodayMessage copyWith({
    int? heartCount,
    int? shareCount,
  }) {
    return TodayMessage(
      id: id,
      publishDate: publishDate,
      language: language,
      verseReference: verseReference,
      verseText: verseText,
      message: message,
      imageUrl: imageUrl,
      shareUrl: shareUrl,
      hintTitle: hintTitle,
      hintSummary: hintSummary,
      articleTitle: articleTitle,
      articleBody: articleBody,
      relatedPlanTemplateKey: relatedPlanTemplateKey,
      relatedPlanTitle: relatedPlanTitle,
      relatedPlanChapters: relatedPlanChapters,
      relatedPlanMinutes: relatedPlanMinutes,
      heartCount: heartCount ?? this.heartCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }

  factory TodayMessage.fromJson(Map<String, dynamic> json) {
    return TodayMessage(
      id: _requiredString(json, 'id'),
      publishDate: _requiredString(json, 'publish_date'),
      language: _stringValue(json['language'], fallback: 'en'),
      verseReference: _requiredString(json, 'verse_reference'),
      verseText: _nullableString(json['verse_text']),
      message: _nullableString(json['message']),
      imageUrl: _nullableString(json['image_url']),
      shareUrl: _nullableString(json['share_url']),
      hintTitle: _nullableString(json['hint_title']),
      hintSummary: _nullableString(json['hint_summary']),
      articleTitle: _nullableString(json['article_title']),
      articleBody: _nullableString(json['article_body']),
      relatedPlanTemplateKey: _nullableString(
        json['related_plan_template_key'],
      ),
      relatedPlanTitle: _nullableString(json['related_plan_title']),
      relatedPlanChapters: _nullableInt(json['related_plan_chapters']),
      relatedPlanMinutes: _nullableInt(json['related_plan_minutes']),
      heartCount: _intValue(json['heart_count']),
      shareCount: _intValue(json['share_count']),
    );
  }
}

class TodayMessageEngagement {
  const TodayMessageEngagement({
    required this.id,
    required this.heartCount,
    required this.shareCount,
  });

  final String id;
  final int heartCount;
  final int shareCount;

  factory TodayMessageEngagement.fromJson(Map<String, dynamic> json) {
    return TodayMessageEngagement(
      id: _requiredString(json, 'id'),
      heartCount: _intValue(json['heart_count']),
      shareCount: _intValue(json['share_count']),
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

int _intValue(Object? value) {
  return _nullableInt(value) ?? 0;
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

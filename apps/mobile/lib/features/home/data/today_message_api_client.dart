import 'package:dio/dio.dart';

import '../../../core/api/hunny_api_client.dart';
import '../../../core/api/hunny_api_config.dart';

class TodayMessageApiClient {
  TodayMessageApiClient({
    HunnyApiConfig? config,
    HunnyApiReachability? reachability,
  })  : _config = config ?? HunnyApiConfig.fromEnvironment(),
        _reachability = reachability ??
            HunnyApiReachability(
              config: config ?? HunnyApiConfig.fromEnvironment(),
            );

  final HunnyApiConfig _config;
  final HunnyApiReachability _reachability;

  bool get isConfigured => _config.isConfigured;

  Future<TodayMessage?> fetchTodayMessage({
    required String date,
    String language = 'en',
  }) async {
    if (!_config.isConfigured) return null;
    if (!await _reachability.canReachApi()) return null;

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(_config);
      response = await dio.get<dynamic>(
        '/api/v1/today-message',
        queryParameters: {
          'date': date,
          'language': language,
        },
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      rethrow;
    }
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

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(_config);
      response = await dio.post<dynamic>(
        '/api/v1/today-message/$id/$action',
        data: const <String, dynamic>{},
        options: Options(contentType: Headers.jsonContentType),
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      rethrow;
    }
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

class TodayMessageLinkedPlanSummary {
  const TodayMessageLinkedPlanSummary({
    required this.id,
    required this.templateKey,
    required this.title,
    required this.totalChapters,
    required this.estimatedMinutes,
    required this.ctaLabel,
  });

  final String id;
  final String templateKey;
  final String title;
  final int? totalChapters;
  final int? estimatedMinutes;
  final String? ctaLabel;

  factory TodayMessageLinkedPlanSummary.fromJson(Map<String, dynamic> json) {
    return TodayMessageLinkedPlanSummary(
      id: _requiredString(json, 'id'),
      templateKey: _requiredString(json, 'template_key'),
      title: _requiredString(json, 'title'),
      totalChapters: _nullableInt(json['total_chapters']),
      estimatedMinutes: _nullableInt(json['estimated_minutes']),
      ctaLabel: _nullableString(json['cta_label']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_key': templateKey,
      'title': title,
      'total_chapters': totalChapters,
      'estimated_minutes': estimatedMinutes,
      'cta_label': ctaLabel,
    };
  }
}

class TodayMessageLinkedContentSummary {
  const TodayMessageLinkedContentSummary({
    required this.id,
    required this.slug,
    required this.contentType,
    required this.title,
    required this.summary,
    required this.coverImageUrl,
    required this.relatedPlans,
  });

  final String id;
  final String slug;
  final String contentType;
  final String title;
  final String? summary;
  final String? coverImageUrl;
  final List<TodayMessageLinkedPlanSummary> relatedPlans;

  factory TodayMessageLinkedContentSummary.fromJson(Map<String, dynamic> json) {
    final relatedPlans = json['related_plans'];
    return TodayMessageLinkedContentSummary(
      id: _requiredString(json, 'id'),
      slug: _requiredString(json, 'slug'),
      contentType: _requiredString(json, 'content_type'),
      title: _requiredString(json, 'title'),
      summary: _nullableString(json['summary']),
      coverImageUrl: _nullableString(json['cover_image_url']),
      relatedPlans: relatedPlans is List
          ? relatedPlans
              .whereType<Map<String, dynamic>>()
              .map(TodayMessageLinkedPlanSummary.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'content_type': contentType,
      'title': title,
      'summary': summary,
      'cover_image_url': coverImageUrl,
      'related_plans': relatedPlans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class TodayMessage {
  const TodayMessage({
    required this.id,
    required this.contentId,
    required this.publishDate,
    required this.language,
    required this.verseReference,
    required this.bibleVersion,
    required this.verseText,
    required this.imageUrl,
    required this.shareImageUrl,
    required this.shareImagePublicId,
    required this.shareUrl,
    required this.hintTitle,
    required this.hintSummary,
    required this.linkedContent,
    required this.heartCount,
    required this.shareCount,
  });

  final String id;
  final String? contentId;
  final String publishDate;
  final String language;
  final String verseReference;
  final String? bibleVersion;
  final String? verseText;
  final String? imageUrl;
  final String? shareImageUrl;
  final String? shareImagePublicId;
  final String? shareUrl;
  final String? hintTitle;
  final String? hintSummary;
  final TodayMessageLinkedContentSummary? linkedContent;
  final int heartCount;
  final int shareCount;

  String get primaryText => verseText ?? verseReference;

  String get referenceLabel {
    final version = bibleVersion;
    if (version == null) return verseReference;
    return '$verseReference · $version';
  }

  String get reflectionTitle => hintTitle ?? 'A quick reflection';

  String get reflectionSummary =>
      hintSummary ??
      'This verse invites a slower look at how God works through ordinary days.';

  bool get hasMoreDetails =>
      hintTitle != null ||
      hintSummary != null ||
      linkedContent != null;

  String get shareTitle => '$verseReference | Hunny Bible Tracker';

  /// Short label for iOS share-sheet preview when sharing the image only.
  String get sharePreviewTitle {
    final quote = primaryText.trim();
    final reference = verseReference.trim();
    if (quote.isEmpty) return shareTitle;
    if (reference.isEmpty || quote == reference) return quote;
    const maxQuoteLength = 72;
    final clippedQuote = quote.length <= maxQuoteLength
        ? quote
        : '${quote.substring(0, maxQuoteLength - 1).trimRight()}…';
    return '$clippedQuote — $reference';
  }

  String get shareText {
    final parts = <String>[];
    final quote = primaryText.trim();
    if (quote.isNotEmpty) {
      parts.add(quote);
    }
    final reference = verseReference.trim();
    if (reference.isNotEmpty && reference != quote) {
      parts.add(reference);
    }
    final url = shareUrl?.trim();
    if (url != null && url.isNotEmpty) {
      parts.add(url);
    }
    return parts.join('\n\n');
  }

  TodayMessage copyWith({
    int? heartCount,
    int? shareCount,
  }) {
    return TodayMessage(
      id: id,
      contentId: contentId,
      publishDate: publishDate,
      language: language,
      verseReference: verseReference,
      bibleVersion: bibleVersion,
      verseText: verseText,
      imageUrl: imageUrl,
      shareImageUrl: shareImageUrl,
      shareImagePublicId: shareImagePublicId,
      shareUrl: shareUrl,
      hintTitle: hintTitle,
      hintSummary: hintSummary,
      linkedContent: linkedContent,
      heartCount: heartCount ?? this.heartCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }

  factory TodayMessage.fromJson(Map<String, dynamic> json) {
    final linkedContent = json['linked_content'];
    return TodayMessage(
      id: _requiredString(json, 'id'),
      contentId: _nullableString(json['content_id']),
      publishDate: _requiredString(json, 'publish_date'),
      language: _stringValue(json['language'], fallback: 'en'),
      verseReference: _requiredString(json, 'verse_reference'),
      bibleVersion: _nullableString(json['bible_version']),
      verseText: _nullableString(json['verse_text']),
      imageUrl: _nullableString(json['image_url']),
      shareImageUrl: _nullableString(json['share_image_url']),
      shareImagePublicId: _nullableString(json['share_image_public_id']),
      shareUrl: _nullableString(json['share_url']),
      hintTitle: _nullableString(json['hint_title']),
      hintSummary: _nullableString(json['hint_summary']),
      linkedContent: linkedContent is Map<String, dynamic>
          ? TodayMessageLinkedContentSummary.fromJson(linkedContent)
          : null,
      heartCount: _intValue(json['heart_count']),
      shareCount: _intValue(json['share_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'publish_date': publishDate,
      'language': language,
      'verse_reference': verseReference,
      'bible_version': bibleVersion,
      'verse_text': verseText,
      'image_url': imageUrl,
      'share_image_url': shareImageUrl,
      'share_image_public_id': shareImagePublicId,
      'share_url': shareUrl,
      'hint_title': hintTitle,
      'hint_summary': hintSummary,
      'linked_content': linkedContent?.toJson(),
      'heart_count': heartCount,
      'share_count': shareCount,
    };
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

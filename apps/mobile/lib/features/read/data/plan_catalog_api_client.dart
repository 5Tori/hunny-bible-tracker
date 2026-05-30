import 'package:dio/dio.dart';

import '../../../core/api/hunny_api_client.dart';
import '../../../core/api/hunny_api_config.dart';

class PlanCatalogFetchFailure implements Exception {
  PlanCatalogFetchFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PlanCatalogApiClient {
  PlanCatalogApiClient({
    HunnyApiConfig? config,
    HunnyApiReachability? reachability,
  })  : _config = config ?? HunnyApiConfig.fromEnvironment(),
        _reachability = reachability ??
            HunnyApiReachability(
              config: config ?? HunnyApiConfig.fromEnvironment(),
            );

  static const catalogConnectTimeout = HunnyApiClient.requestConnectTimeout;
  static const catalogReceiveTimeout = HunnyApiClient.requestReceiveTimeout;

  final HunnyApiConfig _config;
  final HunnyApiReachability _reachability;

  bool get isConfigured => _config.isConfigured;

  Future<List<RemotePlanTemplate>> fetchPublishedPlans({
    String sort = 'featured',
    String? detail,
    bool forceReachability = false,
  }) async {
    if (!_config.isConfigured) {
      throw PlanCatalogFetchFailure(
        'HUNNY_API_BASE_URL is not set for this build.',
      );
    }
    if (!await _reachability.canReachApi(force: forceReachability)) {
      throw PlanCatalogFetchFailure(
        'Cannot reach the Hunny API. Check your connection and try again.',
      );
    }

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(
        _config,
        connectTimeout: catalogConnectTimeout,
        receiveTimeout: catalogReceiveTimeout,
      );
      response = await dio.get<dynamic>(
        '/api/v1/plans',
        queryParameters: {
          'sort': sort,
          if (detail != null) 'detail': detail,
        },
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      if (error is PlanCatalogFetchFailure) rethrow;
      throw PlanCatalogFetchFailure(
        'Could not load plans from the server. Please try again.',
      );
    }

    return _parsePlansResponse(response);
  }

  Future<RemotePlanTemplate> fetchPublishedPlanByIdentifier(
    String identifier, {
    bool forceReachability = false,
  }) async {
    if (!_config.isConfigured) {
      throw PlanCatalogFetchFailure(
        'HUNNY_API_BASE_URL is not set for this build.',
      );
    }
    if (!await _reachability.canReachApi(force: forceReachability)) {
      throw PlanCatalogFetchFailure(
        'Cannot reach the Hunny API. Check your connection and try again.',
      );
    }

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(
        _config,
        connectTimeout: catalogConnectTimeout,
        receiveTimeout: catalogReceiveTimeout,
      );
      response = await dio.get<dynamic>(
        '/api/v1/plans/$identifier',
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      if (error is PlanCatalogFetchFailure) rethrow;
      throw PlanCatalogFetchFailure(
        'Could not load this plan from the server. Please try again.',
      );
    }

    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code == 404) {
      throw PlanCatalogFetchFailure('This plan is no longer available.');
    }
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw PlanCatalogFetchFailure(
        'Could not load this plan (HTTP $code).',
      );
    }

    final plan = data['plan'];
    if (plan is! Map<String, dynamic>) {
      throw const FormatException('Missing plan in /api/v1/plans/[id] response');
    }
    return RemotePlanTemplate.fromJson(plan);
  }

  List<RemotePlanTemplate> _parsePlansResponse(Response<dynamic> response) {
    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw PlanCatalogFetchFailure(
        'Could not load plans from the server (HTTP $code).',
      );
    }

    final plans = data['plans'];
    if (plans is! List) {
      throw PlanCatalogFetchFailure('The server response did not include plans.');
    }

    return plans
        .whereType<Map<String, dynamic>>()
        .map(RemotePlanTemplate.fromJson)
        .toList();
  }
}

class RemotePlanTemplate {
  const RemotePlanTemplate({
    required this.id,
    required this.templateKey,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.shortDescription,
    required this.coverImageUrl,
    required this.planType,
    required this.testamentScope,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.estimatedDays,
    required this.totalChapters,
    required this.primaryBookKey,
    required this.primaryCharacter,
    required this.isBuiltin,
    required this.isPublished,
    required this.featuredRank,
    required this.browseVisible,
    required this.createdAt,
    required this.updatedAt,
    required this.sections,
    required this.tags,
  });

  final String id;
  final String templateKey;
  final String title;
  final String subtitle;
  final String description;
  final String shortDescription;
  final String? coverImageUrl;
  final String planType;
  final String testamentScope;
  final String? difficulty;
  final int? estimatedMinutes;
  final int? estimatedDays;
  final int totalChapters;
  final String? primaryBookKey;
  final String? primaryCharacter;
  final bool isBuiltin;
  final bool isPublished;
  final int? featuredRank;
  final bool browseVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RemotePlanSection> sections;
  final List<RemotePlanTag> tags;

  factory RemotePlanTemplate.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    final tags = json['tags'];
    return RemotePlanTemplate(
      id: _requiredString(json, 'id'),
      templateKey: _requiredString(json, 'template_key'),
      title: _requiredString(json, 'title'),
      subtitle: _stringValue(json['subtitle']),
      description: _stringValue(json['description']),
      shortDescription: _stringValue(json['short_description']),
      coverImageUrl: _nullableString(json['cover_image_url']),
      planType: _stringValue(json['plan_type'], fallback: 'canonical'),
      testamentScope:
          _stringValue(json['testament_scope'], fallback: 'whole_bible'),
      difficulty: _nullableString(json['difficulty']),
      estimatedMinutes: _nullableInt(json['estimated_minutes']),
      estimatedDays: _nullableInt(json['estimated_days']),
      totalChapters: _nullableInt(json['total_chapters']) ?? 0,
      primaryBookKey: _nullableString(json['primary_book_key']),
      primaryCharacter: _nullableString(json['primary_character']),
      isBuiltin: json['is_builtin'] == true,
      isPublished: json['is_published'] == true,
      featuredRank: _nullableInt(json['featured_rank']),
      browseVisible: json['browse_visible'] != false,
      createdAt: _dateTimeValue(json['created_at']),
      updatedAt: _dateTimeValue(json['updated_at']),
      sections: sections is List
          ? sections
              .whereType<Map<String, dynamic>>()
              .map(RemotePlanSection.fromJson)
              .toList()
          : const [],
      tags: tags is List
          ? tags
              .whereType<Map<String, dynamic>>()
              .map(RemotePlanTag.fromJson)
              .toList()
          : const [],
    );
  }
}

class RemotePlanSection {
  const RemotePlanSection({
    required this.id,
    required this.planTemplateId,
    required this.sectionKey,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  final String id;
  final String planTemplateId;
  final String sectionKey;
  final String title;
  final String description;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RemotePlanItem> items;

  factory RemotePlanSection.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return RemotePlanSection(
      id: _requiredString(json, 'id'),
      planTemplateId: _requiredString(json, 'plan_template_id'),
      sectionKey: _requiredString(json, 'section_key'),
      title: _requiredString(json, 'title'),
      description: _stringValue(json['description']),
      orderIndex: _nullableInt(json['order_index']) ?? 0,
      createdAt: _dateTimeValue(json['created_at']),
      updatedAt: _dateTimeValue(json['updated_at']),
      items: items is List
          ? items
              .whereType<Map<String, dynamic>>()
              .map(RemotePlanItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class RemotePlanItem {
  const RemotePlanItem({
    required this.id,
    required this.sectionId,
    required this.orderIndex,
    required this.bookKey,
    required this.startChapter,
    required this.endChapter,
  });

  final String id;
  final String sectionId;
  final int orderIndex;
  final String bookKey;
  final int startChapter;
  final int endChapter;

  factory RemotePlanItem.fromJson(Map<String, dynamic> json) {
    return RemotePlanItem(
      id: _requiredString(json, 'id'),
      sectionId: _requiredString(json, 'section_id'),
      orderIndex: _nullableInt(json['order_index']) ?? 0,
      bookKey: _requiredString(json, 'book_key'),
      startChapter: _nullableInt(json['start_chapter']) ?? 1,
      endChapter: _nullableInt(json['end_chapter']) ?? 1,
    );
  }
}

class RemotePlanTag {
  const RemotePlanTag({
    required this.id,
    required this.key,
    required this.name,
    required this.type,
  });

  final String id;
  final String key;
  final String name;
  final String type;

  factory RemotePlanTag.fromJson(Map<String, dynamic> json) {
    return RemotePlanTag(
      id: _requiredString(json, 'id'),
      key: _requiredString(json, 'key'),
      name: _requiredString(json, 'name'),
      type: _stringValue(json['type']),
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

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime _dateTimeValue(Object? value) {
  final raw = _nullableString(value);
  if (raw == null) return DateTime.now();
  return DateTime.tryParse(raw) ?? DateTime.now();
}

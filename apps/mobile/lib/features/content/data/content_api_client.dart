import 'package:dio/dio.dart';

import '../../../core/api/hunny_api_client.dart';
import '../../../core/api/hunny_api_config.dart';

class ContentApiClient {
  ContentApiClient({
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

  Future<bool> canReachApi() => _reachability.canReachApi();

  Future<List<RemoteContent>> fetchPublishedContent({
    String sort = 'featured',
    String language = 'en',
    String? contentType,
    String? tag,
    int? limit,
  }) async {
    if (!_config.isConfigured) return const [];
    if (!await _reachability.canReachApi()) return const [];

    final query = <String, dynamic>{
      'sort': sort,
      'language': language,
      if (contentType != null && contentType.trim().isNotEmpty)
        'type': contentType,
      if (tag != null && tag.trim().isNotEmpty) 'tag': tag,
      if (limit != null) 'limit': limit,
    };

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(_config);
      response = await dio.get<dynamic>(
        '/api/v1/content',
        queryParameters: query,
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      rethrow;
    }
    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw StateError('GET /api/v1/content failed with status $code');
    }

    final contents = data['contents'];
    if (contents is! List) {
      throw const FormatException(
          'Missing contents in /api/v1/content response');
    }

    return contents
        .whereType<Map<String, dynamic>>()
        .map(RemoteContent.fromJson)
        .toList();
  }

  Future<RemoteContent?> fetchContentByIdentifier(
    String identifier, {
    String language = 'en',
  }) async {
    if (!_config.isConfigured) return null;
    if (!await _reachability.canReachApi()) return null;

    late final Response<dynamic> response;
    try {
      final dio = HunnyApiClient.create(_config);
      response = await dio.get<dynamic>(
        '/api/v1/content/${Uri.encodeComponent(identifier)}',
        queryParameters: {'language': language},
      );
      _reachability.markSuccess();
    } catch (error) {
      _reachability.markFailure(error);
      rethrow;
    }
    final code = response.statusCode ?? 0;
    final data = response.data;
    if (code == 404) return null;
    if (code < 200 || code >= 300 || data is! Map<String, dynamic>) {
      throw StateError(
        'GET /api/v1/content/$identifier failed with status $code',
      );
    }

    final content = data['content'];
    if (content is! Map<String, dynamic>) {
      throw const FormatException('Missing content in content detail response');
    }
    return RemoteContent.fromJson(content);
  }
}

class RemoteContent {
  const RemoteContent({
    required this.id,
    required this.slug,
    required this.contentType,
    required this.language,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.body,
    required this.coverImageUrl,
    required this.coverImagePublicId,
    required this.authorId,
    required this.primaryVerseReference,
    required this.bibleVersion,
    required this.verseText,
    required this.durationSeconds,
    required this.externalUrl,
    required this.isPublished,
    required this.isArchived,
    required this.publishedAt,
    required this.featuredRank,
    required this.browseVisible,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.assets,
    required this.tags,
    required this.relatedPlans,
  });

  final String id;
  final String slug;
  final String contentType;
  final String language;
  final String title;
  final String? subtitle;
  final String? summary;
  final String? body;
  final String? coverImageUrl;
  final String? coverImagePublicId;
  final String? authorId;
  final String? primaryVerseReference;
  final String? bibleVersion;
  final String? verseText;
  final int? durationSeconds;
  final String? externalUrl;
  final bool isPublished;
  final bool isArchived;
  final DateTime? publishedAt;
  final int? featuredRank;
  final bool browseVisible;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RemoteContentAuthor? author;
  final List<RemoteContentAsset> assets;
  final List<RemoteContentTag> tags;
  final List<RemoteContentRelatedPlan> relatedPlans;

  bool get hasRelatedPlans => relatedPlans.isNotEmpty;

  factory RemoteContent.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final assets = json['assets'];
    final tags = json['tags'];
    final relatedPlans = json['related_plans'];
    return RemoteContent(
      id: _requiredString(json, 'id'),
      slug: _requiredString(json, 'slug'),
      contentType: _requiredString(json, 'content_type'),
      language: _stringValue(json['language'], fallback: 'en'),
      title: _requiredString(json, 'title'),
      subtitle: _nullableString(json['subtitle']),
      summary: _nullableString(json['summary']),
      body: _nullableString(json['body']),
      coverImageUrl: _nullableString(json['cover_image_url']),
      coverImagePublicId: _nullableString(json['cover_image_public_id']),
      authorId: _nullableString(json['author_id']),
      primaryVerseReference: _nullableString(json['primary_verse_reference']),
      bibleVersion: _nullableString(json['bible_version']),
      verseText: _nullableString(json['verse_text']),
      durationSeconds: _nullableInt(json['duration_seconds']),
      externalUrl: _nullableString(json['external_url']),
      isPublished: json['is_published'] == true,
      isArchived: json['is_archived'] == true,
      publishedAt: _nullableDateTime(json['published_at']),
      featuredRank: _nullableInt(json['featured_rank']),
      browseVisible: json['browse_visible'] != false,
      metadata: _mapValue(json['metadata']),
      createdAt: _dateTimeValue(json['created_at']),
      updatedAt: _dateTimeValue(json['updated_at']),
      author: author is Map<String, dynamic>
          ? RemoteContentAuthor.fromJson(author)
          : null,
      assets: assets is List
          ? assets
              .whereType<Map<String, dynamic>>()
              .map(RemoteContentAsset.fromJson)
              .toList()
          : const [],
      tags: tags is List
          ? tags
              .whereType<Map<String, dynamic>>()
              .map(RemoteContentTag.fromJson)
              .toList()
          : const [],
      relatedPlans: relatedPlans is List
          ? relatedPlans
              .whereType<Map<String, dynamic>>()
              .map(RemoteContentRelatedPlan.fromJson)
              .toList()
          : const [],
    );
  }
}

class RemoteContentAuthor {
  const RemoteContentAuthor({
    required this.id,
    required this.slug,
    required this.displayName,
    required this.bio,
    required this.avatarImageUrl,
    required this.avatarImagePublicId,
    required this.websiteUrl,
    required this.isVerified,
    required this.isActive,
  });

  final String id;
  final String slug;
  final String displayName;
  final String? bio;
  final String? avatarImageUrl;
  final String? avatarImagePublicId;
  final String? websiteUrl;
  final bool isVerified;
  final bool isActive;

  factory RemoteContentAuthor.fromJson(Map<String, dynamic> json) {
    return RemoteContentAuthor(
      id: _requiredString(json, 'id'),
      slug: _requiredString(json, 'slug'),
      displayName: _requiredString(json, 'display_name'),
      bio: _nullableString(json['bio']),
      avatarImageUrl: _nullableString(json['avatar_image_url']),
      avatarImagePublicId: _nullableString(json['avatar_image_public_id']),
      websiteUrl: _nullableString(json['website_url']),
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] != false,
    );
  }
}

class RemoteContentAsset {
  const RemoteContentAsset({
    required this.id,
    required this.contentId,
    required this.assetType,
    required this.assetRole,
    required this.orderIndex,
    required this.title,
    required this.caption,
    required this.altText,
    required this.url,
    required this.publicId,
    required this.provider,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.durationSeconds,
    required this.metadata,
  });

  final String id;
  final String contentId;
  final String assetType;
  final String assetRole;
  final int orderIndex;
  final String? title;
  final String? caption;
  final String? altText;
  final String url;
  final String? publicId;
  final String? provider;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final Map<String, dynamic> metadata;

  factory RemoteContentAsset.fromJson(Map<String, dynamic> json) {
    return RemoteContentAsset(
      id: _requiredString(json, 'id'),
      contentId: _requiredString(json, 'content_id'),
      assetType: _requiredString(json, 'asset_type'),
      assetRole: _stringValue(json['asset_role'], fallback: 'body'),
      orderIndex: _nullableInt(json['order_index']) ?? 0,
      title: _nullableString(json['title']),
      caption: _nullableString(json['caption']),
      altText: _nullableString(json['alt_text']),
      url: _requiredString(json, 'url'),
      publicId: _nullableString(json['public_id']),
      provider: _nullableString(json['provider']),
      mimeType: _nullableString(json['mime_type']),
      width: _nullableInt(json['width']),
      height: _nullableInt(json['height']),
      durationSeconds: _nullableInt(json['duration_seconds']),
      metadata: _mapValue(json['metadata']),
    );
  }
}

class RemoteContentTag {
  const RemoteContentTag({
    required this.id,
    required this.type,
    required this.key,
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  final String id;
  final String type;
  final String key;
  final String name;
  final String? description;
  final int sortOrder;

  factory RemoteContentTag.fromJson(Map<String, dynamic> json) {
    return RemoteContentTag(
      id: _requiredString(json, 'id'),
      type: _requiredString(json, 'type'),
      key: _requiredString(json, 'key'),
      name: _requiredString(json, 'name'),
      description: _nullableString(json['description']),
      sortOrder: _nullableInt(json['sort_order']) ?? 0,
    );
  }
}

class RemoteContentRelatedPlan {
  const RemoteContentRelatedPlan({
    required this.relationshipType,
    required this.displayOrder,
    required this.ctaLabel,
    required this.id,
    required this.templateKey,
    required this.title,
    required this.subtitle,
    required this.coverImageUrl,
    required this.totalChapters,
    required this.estimatedMinutes,
  });

  final String relationshipType;
  final int displayOrder;
  final String? ctaLabel;
  final String id;
  final String templateKey;
  final String title;
  final String? subtitle;
  final String? coverImageUrl;
  final int? totalChapters;
  final int? estimatedMinutes;

  factory RemoteContentRelatedPlan.fromJson(Map<String, dynamic> json) {
    return RemoteContentRelatedPlan(
      relationshipType:
          _stringValue(json['relationship_type'], fallback: 'related'),
      displayOrder: _nullableInt(json['display_order']) ?? 0,
      ctaLabel: _nullableString(json['cta_label']),
      id: _requiredString(json, 'id'),
      templateKey: _requiredString(json, 'template_key'),
      title: _requiredString(json, 'title'),
      subtitle: _nullableString(json['subtitle']),
      coverImageUrl: _nullableString(json['cover_image_url']),
      totalChapters: _nullableInt(json['total_chapters']),
      estimatedMinutes: _nullableInt(json['estimated_minutes']),
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

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

DateTime? _nullableDateTime(Object? value) {
  final raw = _nullableString(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

DateTime _dateTimeValue(Object? value) {
  return _nullableDateTime(value) ?? DateTime.now();
}

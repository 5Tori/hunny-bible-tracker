import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/hunny_api_config.dart';
import '../../../core/api/hunny_api_models.dart';

class FeedbackApiClient {
  FeedbackApiClient({HunnyApiConfig? config})
      : _config = config ?? HunnyApiConfig.fromEnvironment();

  final HunnyApiConfig _config;

  bool get isConfigured => _config.isConfigured;

  Future<void> submitFeedback({
    required String category,
    required String message,
    String? contactEmail,
    String? signedInEmail,
  }) async {
    if (!_config.isConfigured) {
      throw HunnyApiException('HUNNY_API_BASE_URL is not set');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        headers: const {'Accept': 'application/json'},
        validateStatus: (code) => code != null && code < 600,
      ),
    );
    final response = await dio.post<dynamic>(
      '/api/v1/feedback',
      data: {
        'category': category,
        'message': message,
        'contactEmail': contactEmail,
        'signedInEmail': signedInEmail,
        'source': 'mobile_settings',
        'appVersion': '0.1.0',
        'platform': defaultTargetPlatform.name,
        'metadata': {
          'kDebugMode': kDebugMode,
        },
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw HunnyApiException(
        'Could not send feedback. Try again later.',
        statusCode: code,
      );
    }
  }
}

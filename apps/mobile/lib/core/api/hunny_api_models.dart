class HunnyApiMe {
  const HunnyApiMe({
    required this.sub,
    this.email,
    this.name,
  });

  final String sub;
  final String? email;
  final String? name;

  factory HunnyApiMe.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw const FormatException('Missing user in /api/v1/me response');
    }
    return HunnyApiMe(
      sub: user['sub'] as String? ?? '',
      email: user['email'] as String?,
      name: user['name'] as String?,
    );
  }
}

class HunnySyncPushResult {
  const HunnySyncPushResult({
    required this.serverTime,
    required this.counts,
    required this.acknowledgements,
  });

  final DateTime serverTime;
  final HunnySyncPushCounts counts;
  final HunnySyncAcknowledgements acknowledgements;

  int get totalRows => counts.totalRows;

  factory HunnySyncPushResult.fromJson(Map<String, dynamic> json) {
    return HunnySyncPushResult(
      serverTime: DateTime.parse(json['serverTime'] as String),
      counts: HunnySyncPushCounts.fromJson(
        json['counts'] as Map<String, dynamic>? ?? const {},
      ),
      acknowledgements: HunnySyncAcknowledgements.fromJson(
        json['acknowledgements'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class HunnySyncBootstrapResult {
  const HunnySyncBootstrapResult({
    required this.serverTime,
    required this.userReadingPlans,
    required this.userPlanChapters,
    required this.chapterProgressEntries,
    required this.readingActivities,
    required this.planCompletionEvents,
  });

  final DateTime serverTime;
  final List<Map<String, dynamic>> userReadingPlans;
  final List<Map<String, dynamic>> userPlanChapters;
  final List<Map<String, dynamic>> chapterProgressEntries;
  final List<Map<String, dynamic>> readingActivities;
  final List<Map<String, dynamic>> planCompletionEvents;

  int get totalRows =>
      userReadingPlans.length +
      userPlanChapters.length +
      chapterProgressEntries.length +
      readingActivities.length +
      planCompletionEvents.length;

  factory HunnySyncBootstrapResult.fromJson(Map<String, dynamic> json) {
    return HunnySyncBootstrapResult(
      serverTime: DateTime.parse(json['serverTime'] as String),
      userReadingPlans: _readRows(json['userReadingPlans']),
      userPlanChapters: _readRows(json['userPlanChapters']),
      chapterProgressEntries: _readRows(json['chapterProgressEntries']),
      readingActivities: _readRows(json['readingActivities']),
      planCompletionEvents: _readRows(json['planCompletionEvents']),
    );
  }

  static List<Map<String, dynamic>> _readRows(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}

class HunnySyncPushCounts {
  const HunnySyncPushCounts({
    required this.userReadingPlans,
    required this.userPlanChapters,
    required this.chapterProgressEntries,
    required this.readingActivities,
    required this.planCompletionEvents,
  });

  final int userReadingPlans;
  final int userPlanChapters;
  final int chapterProgressEntries;
  final int readingActivities;
  final int planCompletionEvents;

  int get totalRows =>
      userReadingPlans +
      userPlanChapters +
      chapterProgressEntries +
      readingActivities +
      planCompletionEvents;

  factory HunnySyncPushCounts.fromJson(Map<String, dynamic> json) {
    return HunnySyncPushCounts(
      userReadingPlans: json['userReadingPlans'] as int? ?? 0,
      userPlanChapters: json['userPlanChapters'] as int? ?? 0,
      chapterProgressEntries: json['chapterProgressEntries'] as int? ?? 0,
      readingActivities: json['readingActivities'] as int? ?? 0,
      planCompletionEvents: json['planCompletionEvents'] as int? ?? 0,
    );
  }
}

class HunnySyncAcknowledgements {
  const HunnySyncAcknowledgements({
    required this.userReadingPlans,
    required this.userPlanChapters,
    required this.chapterProgressEntries,
    required this.readingActivities,
    required this.planCompletionEvents,
  });

  final List<HunnySyncRowAck> userReadingPlans;
  final List<HunnySyncRowAck> userPlanChapters;
  final List<HunnySyncRowAck> chapterProgressEntries;
  final List<HunnySyncRowAck> readingActivities;
  final List<HunnySyncRowAck> planCompletionEvents;

  factory HunnySyncAcknowledgements.fromJson(Map<String, dynamic> json) {
    return HunnySyncAcknowledgements(
      userReadingPlans: _readAcks(json['userReadingPlans']),
      userPlanChapters: _readAcks(json['userPlanChapters']),
      chapterProgressEntries: _readAcks(json['chapterProgressEntries']),
      readingActivities: _readAcks(json['readingActivities']),
      planCompletionEvents: _readAcks(json['planCompletionEvents']),
    );
  }

  static List<HunnySyncRowAck> _readAcks(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(HunnySyncRowAck.fromJson)
        .toList();
  }
}

class HunnySyncRowAck {
  const HunnySyncRowAck({
    required this.clientId,
    required this.serverId,
  });

  final String clientId;
  final String serverId;

  factory HunnySyncRowAck.fromJson(Map<String, dynamic> json) {
    return HunnySyncRowAck(
      clientId: json['clientId'] as String? ?? '',
      serverId: json['serverId'] as String? ?? '',
    );
  }
}

class HunnyApiException implements Exception {
  HunnyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'HunnyApiException($statusCode): $message';
}

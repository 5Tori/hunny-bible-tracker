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
    required this.backupVersion,
    required this.payloadHash,
    required this.updatedAt,
    required this.counts,
  });

  final DateTime serverTime;
  final int backupVersion;
  final String payloadHash;
  final DateTime updatedAt;
  final HunnySyncPushCounts counts;

  int get totalItems => counts.totalItems;
  int get totalRows => totalItems;

  factory HunnySyncPushResult.fromJson(Map<String, dynamic> json) {
    final serverTime = DateTime.parse(json['serverTime'] as String);
    return HunnySyncPushResult(
      serverTime: serverTime,
      backupVersion: json['backupVersion'] as int? ?? 1,
      payloadHash: json['payloadHash'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? serverTime,
      counts: HunnySyncPushCounts.fromJson(
        json['counts'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class HunnySyncBootstrapResult {
  const HunnySyncBootstrapResult({
    required this.serverTime,
    required this.backupVersion,
    required this.payloadHash,
    required this.updatedAt,
    required this.payload,
  });

  final DateTime serverTime;
  final int? backupVersion;
  final String? payloadHash;
  final DateTime? updatedAt;
  final Map<String, dynamic>? payload;

  List<Map<String, dynamic>> get plans => _readRows(payload?['plans']);
  List<dynamic> get progress => _readList(payload?['progress']);
  List<dynamic> get activities => _readList(payload?['activities']);
  List<Map<String, dynamic>> get completionEvents =>
      _readRows(payload?['completionEvents']);

  int get totalItems =>
      plans.length +
      progress.length +
      activities.length +
      completionEvents.length;
  int get totalRows => totalItems;

  factory HunnySyncBootstrapResult.fromJson(Map<String, dynamic> json) {
    final serverTime = DateTime.parse(json['serverTime'] as String);
    final rawPayload = json['payload'];
    return HunnySyncBootstrapResult(
      serverTime: serverTime,
      backupVersion: json['backupVersion'] as int?,
      payloadHash: json['payloadHash'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      payload: rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : null,
    );
  }

  bool get hasBackup => payload != null;

  static List<Map<String, dynamic>> _readRows(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  static List<dynamic> _readList(Object? value) {
    if (value is! List) return const [];
    return value;
  }
}

class HunnySyncPushCounts {
  const HunnySyncPushCounts({
    required this.plans,
    required this.progress,
    required this.activities,
    required this.completionEvents,
  });

  final int plans;
  final int progress;
  final int activities;
  final int completionEvents;

  int get totalItems => plans + progress + activities + completionEvents;

  factory HunnySyncPushCounts.fromJson(Map<String, dynamic> json) {
    return HunnySyncPushCounts(
      plans: json['plans'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      activities: json['activities'] as int? ?? 0,
      completionEvents: json['completionEvents'] as int? ?? 0,
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

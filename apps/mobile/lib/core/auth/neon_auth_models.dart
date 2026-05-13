class NeonAuthUser {
  const NeonAuthUser({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  factory NeonAuthUser.fromJson(Map<String, dynamic> json) {
    return NeonAuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }
}

class NeonAuthSession {
  const NeonAuthSession({
    required this.user,
    this.apiJwt,
  });

  final NeonAuthUser user;

  /// JWT from `set-auth-jwt` on `get-session` when present (Better Auth / Neon).
  final String? apiJwt;

  factory NeonAuthSession.fromSignJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw const FormatException('Missing user in auth response');
    }
    return NeonAuthSession(user: NeonAuthUser.fromJson(user));
  }

  factory NeonAuthSession.fromGetSessionJson(
    Map<String, dynamic> json, {
    String? apiJwt,
  }) {
    final user = json['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw const FormatException('Missing user in get-session response');
    }
    return NeonAuthSession(
      user: NeonAuthUser.fromJson(user),
      apiJwt: apiJwt,
    );
  }
}

class NeonAuthException implements Exception {
  NeonAuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'NeonAuthException($code): $message';
}

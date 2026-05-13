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

class HunnyApiException implements Exception {
  HunnyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'HunnyApiException($statusCode): $message';
}

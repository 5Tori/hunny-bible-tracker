class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
}

class AuthSession {
  const AuthSession({
    required this.user,
    this.createdNewAccount = false,
  });

  final AuthUser user;
  final bool createdNewAccount;
}

class AppAuthException implements Exception {
  AppAuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppAuthException($code): $message';
}

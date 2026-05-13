/// Neon Auth (Better Auth) HTTP base URL and trusted [Origin] header.
///
/// Set at build time, e.g.:
/// `flutter run --dart-define=NEON_AUTH_BASE_URL=https://.../neondb/auth`
/// `flutter run --dart-define=NEON_AUTH_ORIGIN=https://your-trusted-origin.example`
///
/// The **Origin** value must be allow-listed in the Neon Console for Auth
/// (same value sent on every request). See `docs/NEON_AUTH.md`.
class NeonAuthConfig {
  const NeonAuthConfig({
    required this.baseUrl,
    required this.trustedOrigin,
  });

  /// Default matches the project’s Neon Auth URL (public). Override per env.
  factory NeonAuthConfig.fromEnvironment() {
    const rawBase = String.fromEnvironment(
      'NEON_AUTH_BASE_URL',
      defaultValue:
          'https://ep-morning-mountain-akevadzl.neonauth.c-3.us-west-2.aws.neon.tech/neondb/auth',
    );
    const origin = String.fromEnvironment(
      'NEON_AUTH_ORIGIN',
      defaultValue: 'https://hunny-bible-tracker.local',
    );
    var base = rawBase.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return NeonAuthConfig(baseUrl: base, trustedOrigin: origin.trim());
  }

  final String baseUrl;
  final String trustedOrigin;

  bool get isConfigured => baseUrl.isNotEmpty;
}

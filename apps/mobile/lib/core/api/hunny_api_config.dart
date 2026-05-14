/// Base URL for `apps/web` API routes (Next.js), no trailing slash.
///
/// iOS Simulator: `http://127.0.0.1:3000`
/// Android emulator: `http://10.0.2.2:3000`
class HunnyApiConfig {
  const HunnyApiConfig._(this.baseUrl);

  factory HunnyApiConfig.fromEnvironment() {
    const raw = String.fromEnvironment(
      'HUNNY_API_BASE_URL',
      defaultValue: '',
    );
    var base = raw.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return HunnyApiConfig._(base);
  }

  final String baseUrl;

  bool get isConfigured => baseUrl.isNotEmpty;
}

import 'dart:math';

/// Historical default before short random ids (DB migration only).
const String kLegacyGuestLocalUserId =
    '00000000-0000-4000-8000-000000000001';

/// Random device profile id (`local_users.id`). 16 chars ≈ 36^16 space.
String generateShortLocalUserId({int length = 16}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random.secure();
  final buf = StringBuffer();
  for (var i = 0; i < length; i++) {
    buf.write(chars[rnd.nextInt(chars.length)]);
  }
  return buf.toString();
}

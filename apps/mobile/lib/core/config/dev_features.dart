import 'package:flutter/foundation.dart';

/// Dev-only surfaces (extra tab, debug screens).
///
/// [showDevTab] is `false` in profile and release builds, so the Dev tab does
/// not ship to TestFlight / Play Store. Use `if (DevFeatures.showDevTab)` when
/// wiring navigation so release tree-shaking can drop dev routes.
abstract final class DevFeatures {
  static const bool showDevTab = kDebugMode;
}

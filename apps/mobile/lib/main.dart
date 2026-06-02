import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/auth/auth_repository.dart';
import '../core/auth/supabase_auth_config.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/read/data/read_repository.dart';
import 'features/stats/data/reading_stats_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final readingStatsRepository = ReadingStatsRepository(database);
  final readRepository = ReadRepository(
    database,
    statsRepository: readingStatsRepository,
  );
  await readRepository.initializeLocalData();

  final supabaseConfig = SupabaseAuthConfig.fromEnvironment();
  var supabaseReady = false;
  if (supabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: supabaseConfig.url,
        anonKey: supabaseConfig.anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      supabaseReady = true;
    } catch (e, stack) {
      debugPrint('Supabase.initialize failed: $e');
      debugPrint('$stack');
      supabaseReady = false;
    }
  }
  final authRepository = AuthRepository(
    supabaseConfig: supabaseConfig,
    supabaseReady: supabaseReady,
    readRepository: readRepository,
  );
  runApp(
    HunnyBibleApp(
      database: database,
      readRepository: readRepository,
      readingStatsRepository: readingStatsRepository,
      authRepository: authRepository,
    ),
  );

  // Do not block cold start on network/auth. The app must stay usable offline.
  unawaited(
    authRepository.refreshRemoteSession().catchError((_) => null),
  );
}

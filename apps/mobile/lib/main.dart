import 'package:flutter/material.dart';

import '../core/auth/auth_repository.dart';
import '../core/auth/neon_auth_api.dart';
import '../core/auth/neon_auth_config.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/read/data/read_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final readRepository = ReadRepository(database);
  await readRepository.initializeLocalData();

  final neonConfig = NeonAuthConfig.fromEnvironment();
  final neonAuthApi = NeonAuthApi(config: neonConfig);
  await neonAuthApi.initIfConfigured();
  final authRepository = AuthRepository(
    neonAuthApi: neonAuthApi,
    readRepository: readRepository,
  );
  try {
    await authRepository.refreshRemoteSession();
  } catch (_) {
    // Offline or invalid cookies — app still runs as guest.
  }

  runApp(
    HunnyBibleApp(
      database: database,
      readRepository: readRepository,
      authRepository: authRepository,
    ),
  );
}

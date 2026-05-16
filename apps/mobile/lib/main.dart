import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/auth/auth_repository.dart';
import '../core/auth/firebase_auth_config.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/read/data/read_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final readRepository = ReadRepository(database);
  await readRepository.initializeLocalData();

  final firebaseConfig = FirebaseAuthConfig.fromEnvironment();
  var firebaseReady = false;
  if (firebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: firebaseConfig.toFirebaseOptions(),
      );
      firebaseReady = true;
    } catch (e, stack) {
      debugPrint('Firebase.initializeApp failed: $e');
      debugPrint('$stack');
      // Mis-matched dart-define (e.g. iOS app id on Android), stale CI secrets, or
      // native layer issues — keep guest mode instead of crashing at cold start.
      firebaseReady = false;
    }
  }
  final authRepository = AuthRepository(
    firebaseConfig: firebaseConfig,
    firebaseReady: firebaseReady,
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

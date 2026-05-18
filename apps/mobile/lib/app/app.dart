import 'package:flutter/material.dart';

import '../core/auth/auth_repository.dart';
import '../core/database/app_database.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/onboarding_gate.dart';
import '../features/read/data/read_repository.dart';

class HunnyBibleApp extends StatelessWidget {
  const HunnyBibleApp({
    super.key,
    required this.database,
    required this.readRepository,
    required this.authRepository,
  });

  final AppDatabase database;
  final ReadRepository readRepository;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunny Bible Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: OnboardingGate(
        readRepository: readRepository,
        authRepository: authRepository,
      ),
    );
  }
}

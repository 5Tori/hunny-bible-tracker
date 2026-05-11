import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../core/theme/app_theme.dart';
import '../features/read/data/read_repository.dart';
import '../features/root/root_shell.dart';

class HunnyBibleApp extends StatelessWidget {
  const HunnyBibleApp({
    super.key,
    required this.database,
    required this.readRepository,
  });

  final AppDatabase database;
  final ReadRepository readRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunny Bible Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: RootShell(readRepository: readRepository),
    );
  }
}

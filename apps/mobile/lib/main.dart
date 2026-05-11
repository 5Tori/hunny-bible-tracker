import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/read/data/read_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final readRepository = ReadRepository(database);
  await readRepository.initializeLocalData();

  runApp(
    HunnyBibleApp(
      database: database,
      readRepository: readRepository,
    ),
  );
}

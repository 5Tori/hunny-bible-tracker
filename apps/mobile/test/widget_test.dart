import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/app/app.dart';
import 'package:hunny_bible_tracker/core/auth/auth_repository.dart';
import 'package:hunny_bible_tracker/core/auth/supabase_auth_config.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/stats/data/reading_stats_repository.dart';

import 'support/test_repositories.dart';

@Tags(['slow'])
void main() {
  testWidgets('HunnyBibleApp renders the main shell', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final (readRepository, readingStatsRepository) =
        await createTestRepositories(database: database);
    await readRepository.completeOnboarding('beginner');
    final authRepository = AuthRepository(
      supabaseConfig: const SupabaseAuthConfig(
        url: '',
        anonKey: '',
      ),
      supabaseReady: false,
      readRepository: readRepository,
    );

    await tester.pumpWidget(
      HunnyBibleApp(
        database: database,
        readRepository: readRepository,
        readingStatsRepository: readingStatsRepository,
        authRepository: authRepository,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Read'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);

    await database.close();
  });
}

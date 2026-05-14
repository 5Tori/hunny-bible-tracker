import 'package:flutter/material.dart';

import '../../../core/api/hunny_api_models.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../read/data/read_repository.dart';

/// One-time prompt after Firebase creates a new account from Google sign-in.
Future<void> showPostAuthBackupPromptIfNeeded({
  required BuildContext context,
  required AuthRepository authRepository,
  required ReadRepository readRepository,
}) async {
  final done = await readRepository
      .getAppSetting(ReadRepository.kAppSettingInitialBackupPromptDone);
  if (done == '1') return;
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      Future<void> markDone() => readRepository.setAppSetting(
            ReadRepository.kAppSettingInitialBackupPromptDone,
            '1',
          );

      return AlertDialog(
        title: const Text('Back up your progress?'),
        content: Text(
          'Your account is ready. We recommend saving your reading data to the '
          'server at least once so you can recover it on a new device. '
          'Full sync is still in progress — this step only checks that backup is reachable.',
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await markDone();
            },
            child: const Text('Maybe later'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await markDone();
              if (!context.mounted) return;
              await _runBackupNow(context, authRepository);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Back up now'),
          ),
        ],
      );
    },
  );
}

Future<void> _runBackupNow(
  BuildContext context,
  AuthRepository authRepository,
) async {
  if (!authRepository.isApiConfigured) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'To enable backup, set HUNNY_API_BASE_URL when you build the app.',
        ),
      ),
    );
    return;
  }
  try {
    final me = await authRepository.fetchApiMe();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connected as ${me.email ?? me.sub}. Full data sync will arrive in a later update.',
        ),
      ),
    );
  } on HunnyApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }
}

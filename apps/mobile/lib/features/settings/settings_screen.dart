import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api/hunny_api_models.dart';
import '../../core/bible/bible_com.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/auth_models.dart';
import '../../core/theme/app_theme.dart';
import '../plans/plans_screen.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import 'data/feedback_api_client.dart';
import 'widgets/auth_sheet.dart';
import 'widgets/post_auth_backup_dialog.dart';
import 'widgets/reading_activity_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authRepository,
    required this.readRepository,
    this.onReadingDataRestored,
    this.onNavigateToRead,
    this.onPreferencesChanged,
  });

  final AuthRepository authRepository;
  final ReadRepository readRepository;
  final VoidCallback? onReadingDataRestored;
  final VoidCallback? onNavigateToRead;
  final VoidCallback? onPreferencesChanged;

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _syncing = false;
  bool _restoring = false;
  bool _apiReachable = false;
  bool _hasPendingChanges = false;
  LocalUserProfile? _profile;
  AuthSession? _session;
  DateTime? _lastSyncedAt;
  BibleComVersion _bibleVersion = BibleComVersion.defaultVersion;
  int _dailyReadingGoalMinutes = 0;
  AccountReadingStats? _readingStats;

  /// Reload account + sync status (e.g. when the Settings tab is opened).
  Future<void> reload() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    AuthSession? session;
    LocalUserProfile? profile;
    DateTime? lastSyncedAt;
    var apiReachable = false;
    var hasPendingChanges = false;
    try {
      session = await widget.authRepository.refreshRemoteSession();
    } catch (_) {
      session = null;
    }
    try {
      profile = await widget.readRepository.getLocalUserProfile();
    } catch (_) {
      profile = null;
    }
    try {
      lastSyncedAt = await widget.readRepository.getLastReadingSyncAt();
    } catch (_) {
      lastSyncedAt = null;
    }
    if (widget.authRepository.isApiConfigured) {
      try {
        apiReachable =
            await widget.authRepository.canReachSyncApi(force: true);
      } catch (_) {
        apiReachable = false;
      }
    }
    try {
      hasPendingChanges = await widget.readRepository.hasUnsyncedReadingChanges();
    } catch (_) {
      hasPendingChanges = false;
    }
    final bibleVersion = await widget.readRepository.getBibleComVersion();
    final dailyReadingGoalMinutes =
        await widget.readRepository.getDailyReadingGoalMinutes();
    AccountReadingStats? readingStats;
    try {
      readingStats = await widget.readRepository.getAccountReadingStats();
    } catch (_) {
      readingStats = null;
    }
    if (!mounted) return;
    setState(() {
      _session = session;
      _profile = profile;
      _lastSyncedAt = lastSyncedAt;
      _apiReachable = apiReachable;
      _hasPendingChanges = hasPendingChanges;
      _bibleVersion = bibleVersion;
      _dailyReadingGoalMinutes = dailyReadingGoalMinutes;
      _readingStats = readingStats;
      _loading = false;
    });
  }

  Future<void> _showBibleVersionSheet() async {
    final selected = await showModalBottomSheet<BibleComVersion>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Bible version',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                for (final version in BibleComVersion.selectable) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(version.label),
                    trailing: _bibleVersion.id == version.id &&
                            _bibleVersion.abbr == version.abbr
                        ? const Icon(Icons.check, color: AppTheme.ink)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(version),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    if (selected.id == _bibleVersion.id &&
        selected.abbr == _bibleVersion.abbr) {
      return;
    }
    await widget.readRepository.setBibleComVersion(selected);
    setState(() => _bibleVersion = selected);
    widget.onPreferencesChanged?.call();
  }

  Future<void> _showDailyReadingGoalSheet() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Daily reading goal',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set a gentle target for how long you\'d like to read each day.',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                      ),
                ),
                const SizedBox(height: 16),
                for (final minutes in ReadRepository.dailyReadingGoalPresets) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ReadRepository.dailyReadingGoalSettingLabel(minutes),
                    ),
                    trailing: _dailyReadingGoalMinutes == minutes
                        ? const Icon(Icons.check, color: AppTheme.ink)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(minutes),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    if (selected == _dailyReadingGoalMinutes) return;

    await widget.readRepository.setDailyReadingGoalMinutes(
      selected <= 0 ? null : selected,
    );
    if (!mounted) return;
    setState(() => _dailyReadingGoalMinutes = selected);
    widget.onPreferencesChanged?.call();
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    if (!widget.authRepository.isApiConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'To enable backup, set HUNNY_API_BASE_URL when you build the app.',
          ),
        ),
      );
      return;
    }

    setState(() => _syncing = true);
    try {
      final result = await widget.authRepository.pushReadingSync();
      final lastSyncedAt = await widget.readRepository.getLastReadingSyncAt();
      final hasPendingChanges =
          await widget.readRepository.hasUnsyncedReadingChanges();
      if (!mounted) return;
      setState(() {
        _lastSyncedAt = lastSyncedAt ?? result.serverTime;
        _hasPendingChanges = hasPendingChanges;
        _apiReachable = true;
      });
      widget.onReadingDataRestored?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.totalRows == 0
                ? 'Backup is up to date.'
                : 'Backed up ${result.totalItems} reading items.',
          ),
        ),
      );
    } on HunnyApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_restoring) return;
    if (!widget.authRepository.isApiConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'To enable restore, set HUNNY_API_BASE_URL when you build the app.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This will download your backed-up reading plans and progress. '
          'Local-only starter plans may be hidden after restore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _restoring = true);
    try {
      final result = await widget.authRepository.bootstrapReadingSync();
      final lastSyncedAt = await widget.readRepository.getLastReadingSyncAt();
      final hasPendingChanges =
          await widget.readRepository.hasUnsyncedReadingChanges();
      if (!mounted) return;
      setState(() {
        _lastSyncedAt = lastSyncedAt ?? result.serverTime;
        _hasPendingChanges = hasPendingChanges;
        _apiReachable = true;
      });
      widget.onReadingDataRestored?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.totalRows == 0
                ? 'No backup data found for this account.'
                : 'Restored ${result.totalItems} reading items.',
          ),
        ),
      );
    } on HunnyApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _openPlans() async {
    final result = await Navigator.of(context).push<PlansScreenPopResult>(
      MaterialPageRoute(
        builder: (context) => PlansScreen(
          readRepository: widget.readRepository,
          initialTab: PlansInitialTab.myPlans,
        ),
      ),
    );
    if (result == null) return;
    if (result.openOnRead) {
      widget.onNavigateToRead?.call();
    } else if (result.dataChanged) {
      widget.onReadingDataRestored?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final session = _session;
    final signedIn = profile?.isAuthLinked == true;
    final accountTitle =
        signedIn ? (session?.user.email ?? '') : (profile?.localUserId ?? '');
    const guestSubtitle = 'Sign in to save your data.';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),

          _SectionLabel(title: 'ACCOUNT'),
          const SizedBox(height: 12),

          // Account card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Icon(
                    signedIn
                        ? Icons.verified_user_outlined
                        : Icons.person_outline,
                    size: 28,
                    color: AppTheme.mutedInk,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (signedIn)
                        Text(
                          accountTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        )
                      else
                        SelectableText(
                          accountTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 15,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      if (!signedIn) ...[
                        const SizedBox(height: 4),
                        Text(
                          guestSubtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.mutedInk,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (signedIn)
                  FilledButton.icon(
                    onPressed: () async {
                      await widget.authRepository.signOut();
                      if (!mounted) return;
                      await _load();
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: !widget.authRepository.isAvailable
                        ? null
                        : () async {
                            await showAuthSheet(
                              context: context,
                              authRepository: widget.authRepository,
                              onAuthSuccess: (
                                  {required createdNewAccount}) async {
                                await _load();
                                if (!context.mounted) return;
                                if (createdNewAccount) {
                                  await showPostAuthBackupPromptIfNeeded(
                                    context: context,
                                    authRepository: widget.authRepository,
                                    readRepository: widget.readRepository,
                                  );
                                }
                              },
                            );
                          },
                    icon: const Icon(Icons.login, size: 16),
                    label: const Text('Sign in'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.ink,
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.library_books_outlined,
            title: 'Manage reading plans',
            onTap: _openPlans,
          ),
          const SizedBox(height: 28),

          _SectionLabel(title: 'SYNC'),
          const SizedBox(height: 12),
          _SyncCard(
            signedIn: signedIn,
            apiConfigured: widget.authRepository.isApiConfigured,
            apiReachable: _apiReachable,
            hasPendingChanges: _hasPendingChanges,
            syncing: _syncing,
            restoring: _restoring,
            lastSyncedAt: _lastSyncedAt,
            onSyncNow: signedIn ? _syncNow : null,
            onRestore: signedIn ? _restoreBackup : null,
          ),
          const SizedBox(height: 28),

          // Preferences
          _SectionLabel(title: 'PREFERENCES'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.language,
            title: 'Timezone',
            trailing: _detectedTimezoneLabel(),
            showChevron: false,
          ),
          _SettingsRow(
            icon: Icons.menu_book_outlined,
            title: 'Bible version',
            trailing: _bibleVersion.label,
            onTap: _showBibleVersionSheet,
          ),
          _SettingsRow(
            icon: Icons.timelapse_outlined,
            title: 'Daily reading goal',
            trailing: ReadRepository.dailyReadingGoalSettingLabel(
              _dailyReadingGoalMinutes,
            ),
            onTap: _showDailyReadingGoalSheet,
          ),
          _SettingsRow(
            icon: Icons.translate,
            title: 'Language',
            trailing: 'English',
            onTap: () => _showLanguageSheet(context),
          ),
          _SettingsRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: 'Off',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications will be added later.'),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // About
          _SectionLabel(title: 'ABOUT'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.help_outline,
            title: 'Help & feedback',
            onTap: () => _showHelpFeedbackSheet(
              context,
              signedInEmail: signedIn ? session?.user.email : null,
            ),
          ),
          const SizedBox(height: 28),

          _SectionLabel(title: 'READING ACTIVITY'),
          const SizedBox(height: 12),
          if (_loading)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_readingStats != null)
            ReadingActivityPanel(stats: _readingStats!)
          else
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                'Reading activity will appear here after you mark chapters as read.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedInk,
                      height: 1.35,
                    ),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v0.5.0+10 · Bible Tracker',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showHelpFeedbackSheet(
  BuildContext context, {
  String? signedInEmail,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.86,
          child: _HelpFeedbackSheet(
            signedInEmail: signedInEmail,
            feedbackApiClient: FeedbackApiClient(),
          ),
        ),
      );
    },
  );
}

enum _HelpFeedbackTab { help, feedback }

enum _FeedbackCategory { bug, idea, other }

class _FeedbackCategoryOption {
  const _FeedbackCategoryOption({
    required this.category,
    required this.label,
    required this.icon,
  });

  final _FeedbackCategory category;
  final String label;
  final IconData icon;
}

const _feedbackCategories = [
  _FeedbackCategoryOption(
    category: _FeedbackCategory.bug,
    label: 'Bug',
    icon: Icons.bug_report_outlined,
  ),
  _FeedbackCategoryOption(
    category: _FeedbackCategory.idea,
    label: 'Idea',
    icon: Icons.lightbulb_outline,
  ),
  _FeedbackCategoryOption(
    category: _FeedbackCategory.other,
    label: 'Other',
    icon: Icons.chat_bubble_outline,
  ),
];

const _faqs = [
  (
    question: 'How do I track my reading progress?',
    answer:
        'Open the Read tab. Tap any chapter square to mark it as read. Your overview stats update automatically.',
  ),
  (
    question: 'Can I change my reading plan?',
    answer:
        'Yes. Go to Read, choose Plans, pick a new plan, and confirm. Existing progress is preserved per book.',
  ),
  (
    question: 'How is the daily message chosen?',
    answer:
        'Daily content is selected for the day and follows your local device timezone.',
  ),
  (
    question: 'Where are my saved verses?',
    answer:
        'Saved items will live in the List tab as the saved content tools expand.',
  ),
  (
    question: 'Do I need an account?',
    answer:
        'No. You can read as a guest. Signing in lets the app connect your data to your account for future sync.',
  ),
];

class _HelpFeedbackSheet extends StatefulWidget {
  const _HelpFeedbackSheet({
    this.signedInEmail,
    required this.feedbackApiClient,
  });

  final String? signedInEmail;
  final FeedbackApiClient feedbackApiClient;

  @override
  State<_HelpFeedbackSheet> createState() => _HelpFeedbackSheetState();
}

class _HelpFeedbackSheetState extends State<_HelpFeedbackSheet> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  _HelpFeedbackTab _tab = _HelpFeedbackTab.help;
  _FeedbackCategory _category = _FeedbackCategory.idea;
  bool _submitting = false;

  bool get _isSignedIn => widget.signedInEmail?.isNotEmpty == true;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    final contactEmail = _isSignedIn
        ? widget.signedInEmail
        : _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim();
    final category = _category.name;

    try {
      await widget.feedbackApiClient.submitFeedback(
        category: category,
        message: message,
        contactEmail: contactEmail,
        signedInEmail: widget.signedInEmail,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            contactEmail == null
                ? 'Thanks for your feedback. We read every message.'
                : 'Thanks for your feedback. We will follow up if needed.',
          ),
        ),
      );
    } on HunnyApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send feedback.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _switchToFeedback() {
    setState(() => _tab = _HelpFeedbackTab.feedback);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Help & feedback',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find quick answers or send us a note.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedInk,
                      ),
                ),
                const SizedBox(height: 22),
                _HelpFeedbackTabs(
                  selected: _tab,
                  onChanged: (tab) => setState(() => _tab = tab),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: _tab == _HelpFeedbackTab.help
                  ? _HelpPanel(
                      key: const ValueKey('help'),
                      onFeedbackTap: _switchToFeedback,
                    )
                  : _FeedbackPanel(
                      key: const ValueKey('feedback'),
                      category: _category,
                      messageController: _messageController,
                      emailController: _emailController,
                      showEmailField: !_isSignedIn,
                      submitting: _submitting,
                      onCategoryChanged: (category) {
                        setState(() => _category = category);
                      },
                      onMessageChanged: () => setState(() {}),
                      onCancel: () => Navigator.of(context).pop(),
                      onSubmit: _submit,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpFeedbackTabs extends StatelessWidget {
  const _HelpFeedbackTabs({
    required this.selected,
    required this.onChanged,
  });

  final _HelpFeedbackTab selected;
  final ValueChanged<_HelpFeedbackTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Help',
            selected: selected == _HelpFeedbackTab.help,
            onTap: () => onChanged(_HelpFeedbackTab.help),
          ),
          _TabButton(
            label: 'Feedback',
            selected: selected == _HelpFeedbackTab.feedback,
            onTap: () => onChanged(_HelpFeedbackTab.feedback),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(3),
        elevation: selected ? 1 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppTheme.ink : AppTheme.mutedInk,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpPanel extends StatelessWidget {
  const _HelpPanel({super.key, required this.onFeedbackTap});

  final VoidCallback onFeedbackTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        for (final faq in _faqs)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 14),
            shape: const Border(
              bottom: BorderSide(color: AppTheme.border),
            ),
            collapsedShape: const Border(
              bottom: BorderSide(color: AppTheme.border),
            ),
            title: Text(
              faq.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        height: 1.45,
                      ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: onFeedbackTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.ink,
            side: BorderSide(color: AppTheme.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Column(
            children: [
              Text(
                "Didn't find your answer?",
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 4),
              Text(
                'Send us a message ->',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    super.key,
    required this.category,
    required this.messageController,
    required this.emailController,
    required this.showEmailField,
    required this.submitting,
    required this.onCategoryChanged,
    required this.onMessageChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final _FeedbackCategory category;
  final TextEditingController messageController;
  final TextEditingController emailController;
  final bool showEmailField;
  final bool submitting;
  final ValueChanged<_FeedbackCategory> onCategoryChanged;
  final VoidCallback onMessageChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final canSubmit = messageController.text.trim().isNotEmpty && !submitting;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        const _FieldLabel('CATEGORY'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final option in _feedbackCategories) ...[
              Expanded(
                child: _FeedbackCategoryButton(
                  option: option,
                  selected: category == option.category,
                  onTap: () => onCategoryChanged(option.category),
                ),
              ),
              if (option != _feedbackCategories.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 28),
        const _FieldLabel('MESSAGE'),
        const SizedBox(height: 10),
        TextField(
          controller: messageController,
          onChanged: (_) => onMessageChanged(),
          maxLength: 1000,
          minLines: 5,
          maxLines: 7,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: "Tell us what's on your mind...",
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              borderSide: BorderSide(color: AppTheme.ink),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${messageController.text.length}/1000',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
        ),
        if (showEmailField) ...[
          const SizedBox(height: 24),
          const _FieldLabel('EMAIL (optional)'),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline, size: 20),
              hintText: 'you@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                borderSide: BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                borderSide: BorderSide(color: AppTheme.ink),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: submitting ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: canSubmit ? onSubmit : null,
                icon: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined, size: 16),
                label: Text(submitting ? 'Sending...' : 'Send'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.mutedInk,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackCategoryButton extends StatelessWidget {
  const _FeedbackCategoryButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _FeedbackCategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.ink,
        backgroundColor: selected ? AppTheme.accentYellowDark : Colors.white,
        side: BorderSide(
          color: selected ? AppTheme.ink : AppTheme.border,
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      ),
      child: Column(
        children: [
          Icon(option.icon, size: 22),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedInk,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
    );
  }
}

Future<void> _showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Language',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('English'),
                trailing: const Icon(Icons.check, color: AppTheme.ink),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _detectedTimezoneLabel() {
  final now = DateTime.now();
  final timezone = now.timeZoneName.trim();
  final utcOffset = now.timeZoneOffset;
  final sign = utcOffset.isNegative ? '-' : '+';
  final hours = utcOffset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (utcOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final offset = 'UTC$sign$hours:$minutes';
  return timezone.isEmpty ? offset : '$timezone ($offset)';
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({
    required this.signedIn,
    required this.apiConfigured,
    required this.apiReachable,
    required this.hasPendingChanges,
    required this.syncing,
    required this.restoring,
    required this.lastSyncedAt,
    required this.onSyncNow,
    required this.onRestore,
  });

  final bool signedIn;
  final bool apiConfigured;
  final bool apiReachable;
  final bool hasPendingChanges;
  final bool syncing;
  final bool restoring;
  final DateTime? lastSyncedAt;
  final VoidCallback? onSyncNow;
  final VoidCallback? onRestore;

  String _statusLabel() {
    if (!apiConfigured) {
      return 'Set HUNNY_API_BASE_URL in your build config to enable sync.';
    }
    if (!signedIn) {
      return 'Sign in to back up and restore reading progress.';
    }
    if (!apiReachable) {
      return 'Sync server looks offline. Check your connection or API URL.';
    }
    if (lastSyncedAt == null) {
      return hasPendingChanges
          ? 'Not synced yet · changes waiting to upload'
          : 'Not synced yet';
    }
    final synced =
        'Last synced ${DateFormat('MMM d, h:mm a').format(lastSyncedAt!.toLocal())}';
    if (hasPendingChanges) {
      return '$synced · changes waiting to upload';
    }
    return synced;
  }

  @override
  Widget build(BuildContext context) {
    final title =
        signedIn ? 'Back up reading progress' : 'Sign in to sync progress';
    final subtitle = signedIn
        ? 'Upload plans, chapter progress, reading activity, and completed history to your account.'
        : 'Your progress stays on this device until you sign in and sync.';
    final busy = syncing || restoring;
    final buttonEnabled = signedIn && apiConfigured && !busy;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.softSurface,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  signedIn && apiReachable
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  size: 22,
                  color: AppTheme.mutedInk,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedInk,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _statusLabel(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: buttonEnabled ? onSyncNow : null,
                  icon: syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(syncing ? 'Syncing...' : 'Sync now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.softSurface,
                    disabledForegroundColor: AppTheme.mutedInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: buttonEnabled ? onRestore : null,
                  icon: restoring
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore, size: 16),
                  label: Text(restoring ? 'Restoring...' : 'Restore'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    disabledForegroundColor: AppTheme.mutedInk,
                    side: BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
            color: AppTheme.mutedInk,
          ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.mutedInk),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      trailing!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedInk,
                          ),
                    ),
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppTheme.mutedInk,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/hunny_api_models.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/neon_auth_models.dart';
import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import 'widgets/neon_auth_sheet.dart';
import 'widgets/post_signup_backup_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authRepository,
    required this.readRepository,
  });

  final AuthRepository authRepository;
  final ReadRepository readRepository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  LocalUserProfile? _profile;
  NeonAuthSession? _session;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    NeonAuthSession? session;
    LocalUserProfile? profile;
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
    if (!mounted) return;
    setState(() {
      _session = session;
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timezone = DateTime.now().timeZoneName;
    final utcOffset = DateTime.now().timeZoneOffset;
    final sign = utcOffset.isNegative ? '-' : '+';
    final hours = utcOffset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (utcOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final tzLabel = 'UTC$sign$hours:$minutes $timezone';

    final profile = _profile;
    final session = _session;
    final signedIn = profile?.isNeonLinked == true;
    final title = signedIn
        ? (session?.user.email ?? 'Signed in')
        : 'Guest';
    final subtitle = widget.authRepository.isAvailable
        ? (signedIn
            ? 'Signed in with Neon Auth. Progress stays on this device until cloud sync is available.'
            : 'Reading data lives on this device only. Sign in with Neon to link your account for future sync.')
        : 'Set NEON_AUTH_BASE_URL and NEON_AUTH_ORIGIN (dart-define) to enable Neon sign-in.';

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  signedIn ? Icons.verified_user_outlined : Icons.person_outline,
                  size: 28,
                  color: AppTheme.mutedInk,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mutedInk,
                            ),
                      ),
                      if (!signedIn && profile != null && !_loading) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Local device ID',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.mutedInk,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SelectableText(
                                profile.localUserId,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      height: 1.35,
                                      color: AppTheme.ink.withValues(alpha: 0.85),
                                    ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Copy local ID',
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: profile.localUserId),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Local device ID copied'),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.copy_outlined,
                                size: 20,
                                color: AppTheme.mutedInk,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (signedIn && session != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Neon user id: ${session.user.id}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: AppTheme.mutedInk,
                              ),
                        ),
                      ],
                      if (signedIn &&
                          widget.authRepository.isApiConfigured) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    try {
                                      final me = await widget.authRepository
                                          .fetchApiMe();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'API /me: ${me.email ?? me.sub}',
                                          ),
                                        ),
                                      );
                                    } on HunnyApiException catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.message),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  },
                            child: const Text('Test Hunny API (/me)'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: !widget.authRepository.isAvailable
                        ? null
                        : () async {
                            await showNeonAuthSheet(
                              context: context,
                              authRepository: widget.authRepository,
                              onAuthSuccess:
                                  ({required createdNewAccount}) async {
                                await _load();
                                if (!context.mounted) return;
                                if (createdNewAccount) {
                                  await showPostSignupBackupPromptIfNeeded(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Preferences
          _SectionLabel(title: 'PREFERENCES'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.language,
            title: 'Timezone',
            trailing: tzLabel,
          ),
          _SettingsRow(
            icon: Icons.translate,
            title: 'Language',
            trailing: 'English',
          ),
          _SettingsRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: 'On',
          ),
          const SizedBox(height: 28),

          // About
          _SectionLabel(title: 'ABOUT'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.help_outline,
            title: 'Help & feedback',
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v0.1.0 · Bible Tracker',
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
  });
  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
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
          if (trailing != null)
            Text(
              trailing!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.mutedInk),
        ],
      ),
    );
  }
}

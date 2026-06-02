import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api/hunny_api_config.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/supabase_auth_config.dart';
import '../../core/config/dev_features.dart';
import '../../core/supabase/remote_read_mode.dart';
import '../../core/theme/app_theme.dart';
import '../find/discover_screen.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../stats/data/reading_stats_repository.dart';
import '../stats/domain/reading_stats_models.dart';

/// Debug-only tools and environment snapshot (Dev tab).
class DevScreen extends StatefulWidget {
  const DevScreen({
    super.key,
    required this.readRepository,
    required this.readingStatsRepository,
    required this.authRepository,
  });

  final ReadRepository readRepository;
  final ReadingStatsRepository readingStatsRepository;
  final AuthRepository authRepository;

  @override
  State<DevScreen> createState() => DevScreenState();
}

class DevScreenState extends State<DevScreen> {
  bool _loading = true;
  ReadingTrackerStats? _tracker;
  LocalUserProfile? _profile;
  DateTime? _lastSyncedAt;
  bool _pendingChanges = false;
  bool _apiReachable = false;

  Future<void> reload() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    ReadingTrackerStats? tracker;
    LocalUserProfile? profile;
    DateTime? lastSyncedAt;
    var pendingChanges = false;
    var apiReachable = false;

    try {
      tracker = await widget.readingStatsRepository.getReadingTrackerStats();
    } catch (_) {}
    try {
      profile = await widget.readRepository.getLocalUserProfile();
    } catch (_) {}
    try {
      lastSyncedAt = await widget.readRepository.getLastReadingSyncAt();
    } catch (_) {}
    try {
      pendingChanges =
          await widget.readRepository.hasUnsyncedReadingChanges();
    } catch (_) {}
    if (widget.authRepository.isApiConfigured) {
      try {
        apiReachable =
            await widget.authRepository.canReachSyncApi(force: true);
      } catch (_) {
        apiReachable = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _tracker = tracker;
      _profile = profile;
      _lastSyncedAt = lastSyncedAt;
      _pendingChanges = pendingChanges;
      _apiReachable = apiReachable;
      _loading = false;
    });
  }

  void _openDiscover() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DiscoverScreen(
          readRepository: widget.readRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiConfig = HunnyApiConfig.fromEnvironment();
    final supabaseConfig = SupabaseAuthConfig.fromEnvironment();
    final remoteReadMode = RemoteReadMode.fromEnvironment();
    final buildMode = kReleaseMode
        ? 'release'
        : kProfileMode
            ? 'profile'
            : 'debug';
    final tracker = _tracker;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Dev'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _Banner(
                  child: Text(
                    'Debug build only — this tab is hidden in release.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Build',
                  rows: [
                    _Row('Mode', buildMode),
                    _Row('Dev tab', DevFeatures.showDevTab ? 'visible' : 'hidden'),
                  ],
                ),
                _Section(
                  title: 'Environment',
                  rows: [
                    _Row(
                      'API base URL',
                      apiConfig.isConfigured ? apiConfig.baseUrl : '(not set)',
                    ),
                    _Row('Remote read', remoteReadMode.name),
                    _Row(
                      'Supabase',
                      supabaseConfig.isConfigured ? 'configured' : 'not configured',
                    ),
                    _Row(
                      'Sync API',
                      widget.authRepository.isApiConfigured
                          ? (_apiReachable ? 'reachable' : 'unreachable')
                          : 'not configured',
                    ),
                  ],
                ),
                _Section(
                  title: 'Local data',
                  rows: [
                    _Row('Local user', _profile?.localUserId ?? '—'),
                    _Row(
                      'Auth linked',
                      _profile?.authUserId?.isNotEmpty == true ? 'yes' : 'no',
                    ),
                    _Row(
                      'Last sync',
                      _lastSyncedAt == null
                          ? 'never'
                          : DateFormat.yMMMd().add_jm().format(_lastSyncedAt!),
                    ),
                    _Row(
                      'Pending sync',
                      _pendingChanges ? 'yes' : 'no',
                    ),
                  ],
                ),
                _Section(
                  title: 'Reading tracker',
                  rows: [
                    _Row(
                      'Today',
                      '${tracker?.chaptersToday ?? 0} ch · '
                      '${tracker?.estimatedMinutesToday ?? 0} min',
                    ),
                    _Row(
                      'This week',
                      '${tracker?.chaptersThisWeek ?? 0} ch · '
                      '${tracker?.estimatedMinutesThisWeek ?? 0} min · '
                      '${tracker?.readingDaysThisWeek ?? 0} days',
                    ),
                    _Row(
                      'This month',
                      '${tracker?.readingDaysThisMonth ?? 0} reading days',
                    ),
                    _Row(
                      'Lifetime',
                      '${tracker?.lifetimeChapters ?? 0} ch · '
                      '${tracker?.lifetimeEstimatedMinutes ?? 0} min · '
                      '${tracker?.lifetimeReadingDays ?? 0} days',
                    ),
                    _Row(
                      'Streak',
                      '${tracker?.currentStreak ?? 0} current · '
                      '${tracker?.longestStreak ?? 0} longest',
                    ),
                    _Row(
                      'Plans',
                      '${tracker?.activePlanCount ?? 0} active · '
                      '${tracker?.completedPlanCount ?? 0} completed',
                    ),
                    _Row(
                      'Avg completion',
                      tracker?.averagePlanCompletionDays == null
                          ? '—'
                          : '${tracker!.averagePlanCompletionDays!.toStringAsFixed(1)} days',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.explore_outlined,
                  label: 'Open Discover (hidden tab)',
                  onTap: _openDiscover,
                ),
              ],
            ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedInk,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppTheme.border),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.mutedInk),
            ],
          ),
        ),
      ),
    );
  }
}

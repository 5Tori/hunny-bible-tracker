import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../root/root_shell.dart';
import '../stats/data/reading_stats_repository.dart';
import 'onboarding_screen.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    super.key,
    required this.readRepository,
    required this.readingStatsRepository,
    required this.authRepository,
  });

  final ReadRepository readRepository;
  final ReadingStatsRepository readingStatsRepository;
  final AuthRepository authRepository;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _loading = true;
  bool _showOnboarding = false;
  int _initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final show = await widget.readRepository.shouldShowOnboarding();
    if (!mounted) return;
    setState(() {
      _showOnboarding = show;
      _loading = false;
    });
  }

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
      _initialTabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        readRepository: widget.readRepository,
        onFinished: _finishOnboarding,
      );
    }

    return RootShell(
      readRepository: widget.readRepository,
      readingStatsRepository: widget.readingStatsRepository,
      authRepository: widget.authRepository,
      initialIndex: _initialTabIndex,
    );
  }
}

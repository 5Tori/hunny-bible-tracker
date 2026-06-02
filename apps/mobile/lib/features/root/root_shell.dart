import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/config/dev_features.dart';
import '../../core/theme/app_theme.dart';
import '../dev/dev_screen.dart';
import '../home/home_screen.dart';
import '../read/data/read_repository.dart';
import '../read/read_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/data/reading_stats_repository.dart';

/// Bottom tabs: Home · Read · Settings (+ Dev in debug builds only).
class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    required this.readRepository,
    required this.readingStatsRepository,
    required this.authRepository,
    this.initialIndex = 0,
  });

  final ReadRepository readRepository;
  final ReadingStatsRepository readingStatsRepository;
  final AuthRepository authRepository;
  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const _settingsTabIndex = 2;
  static const _devTabIndex = 3;

  int get _tabCount => DevFeatures.showDevTab ? 4 : 3;

  late int _selectedIndex = widget.initialIndex.clamp(0, _tabCount - 1);
  late final List<bool> _visitedTabs = List.generate(
    _tabCount,
    (index) => index == _selectedIndex,
  );
  int _readRefreshToken = 0;
  var _readScrollToLastReadOnOpen = false;
  final _homeKey = GlobalKey<HomeScreenState>();
  final _settingsKey = GlobalKey<SettingsScreenState>();
  final _devKey = GlobalKey<DevScreenState>();

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedTabs[index] = true;
      if (index == 1) {
        _readScrollToLastReadOnOpen = false;
      }
    });
    if (index == 0) {
      _homeKey.currentState?.refresh();
    } else if (index == _settingsTabIndex) {
      _settingsKey.currentState?.reload();
    } else if (DevFeatures.showDevTab && index == _devTabIndex) {
      _devKey.currentState?.reload();
    }
  }

  void _openReadTab({bool scrollToLastRead = false, bool refreshRead = true}) {
    setState(() {
      _selectedIndex = 1;
      _visitedTabs[1] = true;
      _readScrollToLastReadOnOpen = scrollToLastRead;
      if (refreshRead) _readRefreshToken += 1;
    });
    _homeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_tabCount, _buildTab),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                Expanded(
                  child: _BottomNavItem(
                    selected: _selectedIndex == 0,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    onTap: () => _selectTab(0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    selected: _selectedIndex == 1,
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: 'Read',
                    onTap: () => _selectTab(1),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    selected: _selectedIndex == _settingsTabIndex,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                    onTap: () => _selectTab(_settingsTabIndex),
                  ),
                ),
                if (DevFeatures.showDevTab)
                  Expanded(
                    child: _BottomNavItem(
                      selected: _selectedIndex == _devTabIndex,
                      icon: Icons.bug_report_outlined,
                      selectedIcon: Icons.bug_report,
                      label: 'Dev',
                      onTap: () => _selectTab(_devTabIndex),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    if (!_visitedTabs[index]) return const SizedBox.shrink();

    return switch (index) {
      0 => HomeScreen(
          key: _homeKey,
          readRepository: widget.readRepository,
          readingStatsRepository: widget.readingStatsRepository,
          onReadTap: ({bool scrollToLastRead = false}) =>
              _openReadTab(scrollToLastRead: scrollToLastRead),
        ),
      1 => ReadScreen(
          key: ValueKey(_readRefreshToken),
          readRepository: widget.readRepository,
          scrollToLastReadOnOpen: _readScrollToLastReadOnOpen,
        ),
      _settingsTabIndex => SettingsScreen(
          key: _settingsKey,
          authRepository: widget.authRepository,
          readRepository: widget.readRepository,
          readingStatsRepository: widget.readingStatsRepository,
          onReadingDataRestored: () {
            setState(() => _readRefreshToken += 1);
            _homeKey.currentState?.refresh();
            _settingsKey.currentState?.reload(includeStats: true);
          },
          onNavigateToRead: _openReadTab,
          onPreferencesChanged: () {
            setState(() => _readRefreshToken += 1);
            _homeKey.currentState?.refresh();
            _settingsKey.currentState?.reload();
          },
        ),
      _devTabIndex when DevFeatures.showDevTab => DevScreen(
          key: _devKey,
          readRepository: widget.readRepository,
          readingStatsRepository: widget.readingStatsRepository,
          authRepository: widget.authRepository,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.ink : AppTheme.mutedInk;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: color,
                  letterSpacing: selected ? -0.2 : 0,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 3,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 3,
                    width: selected ? 28 : 0,
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

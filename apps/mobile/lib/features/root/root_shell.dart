import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_theme.dart';
import '../find/discover_screen.dart';
import '../home/home_screen.dart';
import '../read/data/read_repository.dart';
import '../read/read_screen.dart';
import '../settings/settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    required this.readRepository,
    required this.authRepository,
    this.initialIndex = 0,
  });

  final ReadRepository readRepository;
  final AuthRepository authRepository;
  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _selectedIndex = widget.initialIndex;
  late final List<bool> _visitedTabs = List.generate(
    4,
    (index) => index == widget.initialIndex,
  );
  int _readRefreshToken = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedTabs[index] = true;
    });
    if (index == 0) {
      _homeKey.currentState?.refresh();
    }
  }

  void _openReadTab({bool refreshRead = true}) {
    setState(() {
      _selectedIndex = 2;
      _visitedTabs[2] = true;
      if (refreshRead) _readRefreshToken += 1;
    });
    _homeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(4, _buildTab),
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
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore,
                    label: 'Discover',
                    onTap: () => _selectTab(1),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    selected: _selectedIndex == 2,
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    label: 'Read',
                    onTap: () => _selectTab(2),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    selected: _selectedIndex == 3,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                    onTap: () => _selectTab(3),
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
          onReadTap: () => _selectTab(2),
        ),
      1 => DiscoverScreen(),
      2 => ReadScreen(
          key: ValueKey(_readRefreshToken),
          readRepository: widget.readRepository,
        ),
      3 => SettingsScreen(
          authRepository: widget.authRepository,
          readRepository: widget.readRepository,
          onReadingDataRestored: () {
            setState(() => _readRefreshToken += 1);
            _homeKey.currentState?.refresh();
          },
          onNavigateToRead: _openReadTab,
          onPreferencesChanged: () => setState(() => _readRefreshToken += 1),
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

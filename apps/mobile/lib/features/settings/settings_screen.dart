import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timezone = DateTime.now().timeZoneName;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          const _SettingsTile(
            title: 'Account',
            subtitle: 'Guest mode. Backup and sync will be added later.',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            title: 'Timezone',
            subtitle: timezone,
            icon: Icons.schedule_outlined,
          ),
          const SizedBox(height: 12),
          const _SettingsTile(
            title: 'Language',
            subtitle: 'English. Korean-ready data structure planned.',
            icon: Icons.language_outlined,
          ),
          const SizedBox(height: 12),
          const _SettingsTile(
            title: 'Sync',
            subtitle: 'Offline only for v0.1. Neon backup will come later.',
            icon: Icons.cloud_off_outlined,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
      ),
    );
  }
}

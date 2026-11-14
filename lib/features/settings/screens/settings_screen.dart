import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/business_state.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: <Widget>[
          // User profile card
          AppCard(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (user?.fullName.isNotEmpty == true ? user!.fullName : '?')[0].toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user?.fullName ?? 'User', style: theme.textTheme.titleMedium),
                      if (user?.email != null)
                        Text(user!.email!, style: theme.textTheme.bodySmall),
                      if (user?.phone != null && user?.email == null)
                        Text(user!.phone!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appearance section
          _SectionHeader(title: 'Appearance'),
          AppCard(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Dark mode'),
                  subtitle: Text(
                    themeMode == ThemeMode.dark
                        ? 'On'
                        : themeMode == ThemeMode.light
                            ? 'Off'
                            : 'Follow system',
                  ),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (v) {
                      ref.read(themeModeProvider.notifier).state =
                          v ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Business section
          _SectionHeader(title: 'Business'),
          AppCard(
            child: Column(
              children: <Widget>[
                _SettingsTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  onTap: () => context.push('/inventory'),
                ),
                _SettingsTile(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  onTap: () => context.push('/customers'),
                ),
                _SettingsTile(
                  icon: Icons.business_outlined,
                  title: 'Suppliers',
                  onTap: () => context.push('/suppliers'),
                ),
                _SettingsTile(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Purchases',
                  onTap: () => context.push('/purchases'),
                ),
                _SettingsTile(
                  icon: Icons.wallet_outlined,
                  title: 'Expenses',
                  onTap: () => context.push('/expenses'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Management section
          _SectionHeader(title: 'Management'),
          AppCard(
            child: Column(
              children: <Widget>[
                _SettingsTile(
                  icon: Icons.people_alt_outlined,
                  title: 'Staff',
                  onTap: () => context.push('/staff'),
                ),
                _SettingsTile(
                  icon: Icons.account_tree_outlined,
                  title: 'Branches',
                  onTap: () => context.push('/branches'),
                ),
                _SettingsTile(
                  icon: Icons.credit_card,
                  title: 'Subscription',
                  onTap: () => context.push('/subscription'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account section
          _SectionHeader(title: 'Account'),
          AppCard(
            child: Column(
              children: <Widget>[
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password — available in profile settings')),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.logout,
                  title: 'Sign out',
                  iconColor: Colors.red,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    ref.read(businessProvider.notifier).clear();
                    if (context.mounted) context.go('/welcome');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'RetailOS v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

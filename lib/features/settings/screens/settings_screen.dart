import 'package:flutter/material.dart';
import 'package:retailos_mobile/core/state/auth_state.dart';
import 'package:retailos_mobile/core/state/business_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

/// Settings tab — account, business context, subscription, sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final business = ref.watch(businessProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      (user?.fullName.isNotEmpty ?? false)
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'RetailOS user',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isLight
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: isLight
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Business'),
            const SizedBox(height: 6),
            _SettingTile(
              icon: Icons.storefront_outlined,
              title: business.activeBusiness?.name ?? 'Switch business',
              subtitle: business.activeBusiness?.currency ?? '',
              onTap: () => context.push('/branches'),
            ),
            _SettingTile(
              icon: Icons.people_outline_rounded,
              title: 'Staff & roles',
              onTap: () => context.push('/staff'),
            ),
            _SettingTile(
              icon: Icons.warehouse_outlined,
              title: 'Suppliers',
              onTap: () => context.push('/suppliers'),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Account'),
            const SizedBox(height: 6),
            _SettingTile(
              icon: Icons.workspaces_outline,
              title: 'Subscription',
              onTap: () => context.push('/subscription'),
            ),
            _SettingTile(
              icon: Icons.support_agent_outlined,
              title: 'Help & support',
              onTap: () => context.push('/support'),
            ),
            _SettingTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => context.push('/notifications'),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/welcome');
              },
              icon: Icon(Icons.logout_rounded, color: AppTheme.danger),
              label: Text(
                'Sign out',
                style: TextStyle(color: AppTheme.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight),
        ],
      ),
    );
  }
}

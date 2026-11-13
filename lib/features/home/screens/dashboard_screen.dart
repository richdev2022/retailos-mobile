import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/auth_state.dart';
import '../../../core/state/business_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_card.dart';

/// Dashboard — the home tab. Shows today's sales, top stats and quick actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final business = ref.watch(businessNotifierProvider);
    final currency = business.activeBusiness?.currency ?? 'NGN';
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.fullName.split(' ').first ?? 'there'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              business.activeBusiness?.name ?? 'RetailOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(businessNotifierProvider.notifier).refreshBusinesses(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _DateRangeChip(),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppTheme.primary,
                borderColor: AppTheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s sales',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      MoneyUtils.formatMinor(125_350, currency),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+12.5% vs yesterday',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                children: [
                  StatCard(
                    label: 'Transactions',
                    value: '38',
                    delta: StatDelta.up,
                    deltaLabel: '+6',
                    icon: Icons.receipt_long_rounded,
                  ),
                  StatCard(
                    label: 'Inventory value',
                    value: MoneyUtils.formatMinorCompact(
                        2_400_000, currency),
                    icon: Icons.inventory_2_rounded,
                    iconColor: AppTheme.info,
                  ),
                  StatCard(
                    label: 'Expenses',
                    value: MoneyUtils.formatMinorCompact(45_200, currency),
                    delta: StatDelta.down,
                    deltaLabel: '-4%',
                    icon: Icons.money_off_rounded,
                    iconColor: AppTheme.warning,
                  ),
                  StatCard(
                    label: 'Low stock',
                    value: '7',
                    delta: StatDelta.up,
                    deltaLabel: '+2',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppTheme.danger,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Quick actions',
                action: TextButton(
                  onPressed: () => context.push('/pos'),
                  child: const Text('Open POS'),
                ),
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                children: [
                  _QuickAction(
                    icon: Icons.point_of_sale_rounded,
                    label: 'New sale',
                    onTap: () => context.push('/pos'),
                  ),
                  _QuickAction(
                    icon: Icons.add_shopping_cart_rounded,
                    label: 'Purchase',
                    onTap: () => context.push('/purchases'),
                  ),
                  _QuickAction(
                    icon: Icons.receipt_outlined,
                    label: 'Expense',
                    onTap: () => context.push('/expenses'),
                  ),
                  _QuickAction(
                    icon: Icons.person_add_alt_rounded,
                    label: 'Customer',
                    onTap: () => context.push('/customers'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Recent sales'),
              const SizedBox(height: 8),
              ...List.generate(3, (i) => _SaleRow(currency: currency)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                Formatters.formatDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.sync_rounded, size: 16, color: AppTheme.success),
        const SizedBox(width: 4),
        Text(
          'Synced',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.light
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.currency});
  final String currency;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.receipt_outlined,
                size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.formatReceiptNo('ROS-123'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  Formatters.formatRelative(DateTime.now().subtract(
                      const Duration(minutes: 18))),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            MoneyUtils.formatMinor(8_500, currency),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

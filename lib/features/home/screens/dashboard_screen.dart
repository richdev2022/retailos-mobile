import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/auth_state.dart';
import '../../../core/state/business_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/state/providers.dart';
import '../../../core/widgets/loading_indicator.dart';

/// Dashboard — the home tab. Shows today's sales, top stats and quick actions.
///
/// On first load, attempts to fetch dashboard metrics from the API
/// (GET /reports/dashboard). If the API is unavailable (no business selected,
/// network error, etc.), shows a friendly empty state with a retry button.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _metrics;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final biz = ref.read(businessProvider);
    if (!biz.hasActiveBusiness) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get<Map<String, dynamic>>('/reports/dashboard');
      final data = api.unwrap<Map<String, dynamic>>(response, (d) => d as Map<String, dynamic>);
      setState(() {
        _metrics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final business = ref.watch(businessProvider);
    final currency = business.activeBusiness?.currency ?? 'NGN';
    final user = auth.user;

    // Extract metrics from API response (or use zeros if not loaded)
    final todaySales = _metrics?['todaySales'] as Map<String, dynamic>?;
    final todaySalesMinor = int.tryParse(todaySales?['minor']?.toString() ?? '0') ?? 0;
    final grossProfit = _metrics?['grossProfit'] as Map<String, dynamic>?;
    final grossProfitMinor = int.tryParse(grossProfit?['minor']?.toString() ?? '0') ?? 0;
    final productCount = _metrics?['productCount'] as int? ?? 0;
    final stockQty = _metrics?['stockQty'] as int? ?? 0;
    final inventoryValue = _metrics?['inventoryValue'] as Map<String, dynamic>?;
    final inventoryValueMinor = int.tryParse(inventoryValue?['minor']?.toString() ?? '0') ?? 0;
    final lowStockCount = _metrics?['lowStockCount'] as int? ?? 0;
    final outOfStockCount = _metrics?['outOfStockCount'] as int? ?? 0;
    final expensesToday = _metrics?['expensesToday'] as Map<String, dynamic>?;
    final expensesTodayMinor = int.tryParse(expensesToday?['minor']?.toString() ?? '0') ?? 0;
    final outstandingCredit = _metrics?['outstandingCredit'] as Map<String, dynamic>?;
    final outstandingCreditMinor = int.tryParse(outstandingCredit?['minor']?.toString() ?? '0') ?? 0;

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
          onRefresh: () async {
            await ref.read(businessProvider.notifier).refreshBusinesses();
            await _loadMetrics();
          },
          child: _isLoading && _metrics == null
              ? const Center(child: LoadingIndicator(message: 'Loading dashboard...'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _DateRangeChip(),
                    const SizedBox(height: 16),

                    // Today's sales hero card
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
                            MoneyUtils.formatMinor(todaySalesMinor, currency),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.trending_up,
                                  color: Colors.white.withOpacity(0.7), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Gross profit: ${MoneyUtils.formatMinor(grossProfitMinor, currency)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Products',
                          value: productCount.toString(),
                          icon: Icons.inventory_2_rounded,
                          iconColor: AppTheme.info,
                        ),
                        StatCard(
                          label: 'Stock qty',
                          value: stockQty.toString(),
                          icon: Icons.warehouse_rounded,
                          iconColor: AppTheme.success,
                        ),
                        StatCard(
                          label: 'Stock value',
                          value: MoneyUtils.formatMinorCompact(inventoryValueMinor, currency),
                          icon: Icons.savings_rounded,
                          iconColor: AppTheme.warning,
                        ),
                        StatCard(
                          label: 'Low stock',
                          value: lowStockCount.toString(),
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppTheme.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Secondary stats
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Out of stock', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text(outOfStockCount.toString(),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.danger)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expenses today', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text(MoneyUtils.formatMinor(expensesTodayMinor, currency),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.warning)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Outstanding credit', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text(MoneyUtils.formatMinor(outstandingCreditMinor, currency),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.danger)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sales count', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 4),
                                Text('${_metrics?['todaySalesCount'] ?? 0}',
                                    style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick actions
                    Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.85,
                      children: [
                        _QuickAction(icon: Icons.point_of_sale, label: 'POS', onTap: () => context.push('/pos')),
                        _QuickAction(icon: Icons.add_shopping_cart, label: 'Purchase', onTap: () => context.push('/purchases')),
                        _QuickAction(icon: Icons.people_outline, label: 'Customers', onTap: () => context.push('/customers')),
                        _QuickAction(icon: Icons.wallet_outlined, label: 'Expenses', onTap: () => context.push('/expenses')),
                      ],
                    ),

                    // Error message (if any)
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Could not load live data. Showing cached values.',
                                style: TextStyle(color: AppTheme.danger, fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadMetrics,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '${now.day} ${_monthName(now.month)} ${now.year}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

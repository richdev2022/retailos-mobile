import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = <_ReportItem>[
      _ReportItem('Sales report', Icons.trending_up, () => context.push('/reports/sales')),
      _ReportItem('Profit & Loss', Icons.account_balance_wallet, () => context.push('/reports/profit-loss')),
      _ReportItem('Inventory valuation', Icons.inventory, () => context.push('/reports/inventory')),
      _ReportItem('Stock movements', Icons.swap_horiz, () => context.push('/reports/stock-movement')),
      _ReportItem('Low stock', Icons.warning_amber, () => context.push('/reports/low-stock')),
      _ReportItem('Expiry tracking', Icons.event_busy, () => context.push('/reports/expiry')),
      _ReportItem('Product performance', Icons.star, () => context.push('/reports/product-performance')),
      _ReportItem('Cashier report', Icons.person, () => context.push('/reports/cashier')),
      _ReportItem('Customer credit', Icons.credit_card, () => context.push('/reports/customer-credit')),
      _ReportItem('Supplier report', Icons.local_shipping, () => context.push('/reports/supplier')),
      _ReportItem('Expenses', Icons.receipt, () => context.push('/reports/expenses')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final r = reports[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Icon(r.icon, color: theme.colorScheme.primary)),
                title: Text(r.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right),
                onTap: r.onTap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReportItem {
  const _ReportItem(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

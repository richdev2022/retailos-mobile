import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/state/business_state.dart';
import '../../../core/widgets/stat_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _metrics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final biz = ref.read(businessProvider);
    final bizId = biz.activeBusinessId;
    if (bizId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get<dynamic>('/businesses/$bizId/dashboard');
      final data = api.unwrap<Map<String, dynamic>>(response, (d) => (d as Map<String, dynamic>));
      setState(() => _metrics = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final biz = ref.watch(businessProvider);
    final bizName = biz.activeBusiness?.name ?? 'RetailOS';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dashboard', style: theme.textTheme.titleMedium),
            Text(
              bizName,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorView(error: _error!, onRetry: _load)
                  : _metrics == null
                      ? const SizedBox.shrink()
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          children: <Widget>[
                            _HeroMetrics(metrics: _metrics!['metrics'] as Map<String, dynamic>? ?? <String, dynamic>{}),
                            const SizedBox(height: 16),
                            _SectionTitle(title: 'Recent transactions'),
                            const SizedBox(height: 8),
                            ...(_metrics!['recentTransactions'] as List<dynamic>? ?? const <dynamic>[])
                                .cast<Map<String, dynamic>>()
                                .map(_TransactionTile.fromMap),
                          ],
                        ),
        ),
      ),
    );
  }
}

class _HeroMetrics extends StatelessWidget {
  const _HeroMetrics({required this.metrics});
  final Map<String, dynamic> metrics;

  @override
  Widget build(BuildContext context) {
    final sales = metrics['todaySalesMinor'] as String? ?? '0';
    final profit = metrics['todayGrossProfitMinor'] as String? ?? '0';
    final products = metrics['totalProducts'] as int? ?? 0;
    final lowStock = metrics['lowStockCount'] as int? ?? 0;
    final inventoryValue = metrics['inventoryValueMinor'] as String? ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Big today's sales card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Today's sales",
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                _formatMinor(sales),
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                "Gross profit: ${_formatMinor(profit)}",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 2x2 grid of stats
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: <Widget>[
            StatCard(
              label: 'Products',
              value: products.toString(),
              icon: Icons.inventory_2_outlined,
            ),
            StatCard(
              label: 'Inventory value',
              value: _formatMinor(inventoryValue),
              icon: Icons.attach_money,
            ),
            StatCard(
              label: 'Low stock',
              value: lowStock.toString(),
              icon: Icons.warning_amber_outlined,
              valueColor: lowStock > 0 ? Theme.of(context).colorScheme.error : null,
            ),
            StatCard(
              label: 'Out of stock',
              value: (metrics['outOfStockCount'] as int? ?? 0).toString(),
              icon: Icons.error_outline,
              valueColor: (metrics['outOfStockCount'] as int? ?? 0) > 0 ? Theme.of(context).colorScheme.error : null,
            ),
          ],
        ),
      ],
    );
  }

  String _formatMinor(String minor) {
    final n = BigInt.tryParse(minor) ?? BigInt.zero;
    final major = (n / BigInt.from(100)).toStringAsFixed(2);
    return '₦$major';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.receiptNo,
    required this.totalMinor,
    required this.status,
    required this.date,
  });

  final String receiptNo;
  final String totalMinor;
  final String status;
  final DateTime date;

  factory _TransactionTile.fromMap(Map<String, dynamic> map) {
    return _TransactionTile(
      receiptNo: map['receiptNo'] as String? ?? '',
      totalMinor: map['totalMinor']?.toString() ?? '0',
      status: map['status'] as String? ?? '',
      date: DateTime.tryParse(map['saleDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = (BigInt.tryParse(totalMinor) ?? BigInt.zero) / BigInt.from(100);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.receipt, color: theme.colorScheme.primary, size: 18),
        ),
        title: Text(receiptNo, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(_formatDate(date), style: theme.textTheme.bodySmall),
        trailing: Text(
          '₦${total.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_card.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stock In', icon: Icon(Icons.input)),
            Tab(text: 'Stock Out', icon: Icon(Icons.output)),
            Tab(text: 'Movements', icon: Icon(Icons.swap_horiz)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StockInTab(),
          _StockOutTab(),
          _MovementsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products'),
        child: const Icon(Icons.inventory_2),
      ),
    );
  }
}

class _StockInTab extends ConsumerWidget {
  const _StockInTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record Stock Receipt', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    hintText: 'Search product by name or SKU',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Purchase cost'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Supplier (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reference (optional)'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stock receipt recorded')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Record stock-in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StockOutTab extends ConsumerWidget {
  const _StockOutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record Stock Removal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    hintText: 'Search product',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Reason'),
                        items: const [
                          DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                          DropdownMenuItem(value: 'expired', child: Text('Expired')),
                          DropdownMenuItem(value: 'theft', child: Text('Theft/Missing')),
                          DropdownMenuItem(value: 'internal', child: Text('Internal use')),
                          DropdownMenuItem(value: 'return', child: Text('Supplier return')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stock removal recorded')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Record stock-out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MovementsTab extends ConsumerWidget {
  const _MovementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: EmptyState(
        icon: Icons.swap_horiz,
        title: 'No movements yet',
        message: 'Stock movements will appear here once you record stock-in or stock-out.',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';

/// Products list tab — searchable, filterable product catalog.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  String _filter = 'All';
  static const _filters = ['All', 'In stock', 'Low stock', 'Out of stock'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: AppTextField(
                label: 'Search',
                controller: _search,
                hintText: 'Search products, SKU, barcode',
                prefixIcon: const Icon(Icons.search_rounded),
                textInputAction: TextInputAction.search,
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  return AppChip(
                    label: f,
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  );
                },
              ),
            ),
            const Expanded(
              child: _EmptyProducts(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No products yet',
      message: 'Add your first product to start selling.',
      actionLabel: 'Add product',
      onAction: () => context.push('/products/new'),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.name,
    required this.priceMinor,
    required this.currency,
    required this.stock,
  });

  final String name;
  final int priceMinor;
  final String currency;
  final int stock;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(Icons.inventory_2_outlined,
            size: 20, color: AppTheme.primary),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        stock > 0 ? '$stock in stock' : 'Out of stock',
        style: TextStyle(
          fontSize: 12,
          color: stock == 0 ? AppTheme.danger : AppTheme.success,
        ),
      ),
      trailing: Text(
        MoneyUtils.formatMinor(priceMinor, currency),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

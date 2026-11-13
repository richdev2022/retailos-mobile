import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/paginated_list_screen.dart';

class ProductListScreen extends PaginatedListScreen<Map<String, dynamic>> {
  const ProductListScreen({super.key});

  @override
  String get title => 'Products';
  @override
  String get searchHint => 'Search by name, SKU, barcode...';
  @override
  String get endpoint => '/products';

  @override
  Map<String, dynamic> itemFromJson(Map<String, dynamic> json) => json;

  @override
  Widget buildListItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final name = item['name'] as String? ?? '';
    final sku = item['sku'] as String? ?? '';
    final priceMinor = item['sellingPriceMinor']?.toString() ?? '0';
    final price = (BigInt.tryParse(priceMinor) ?? BigInt.zero) / BigInt.from(100);
    final stockQty = item['stockQty'] as int? ?? 0;
    final status = item['status'] as String? ?? 'ACTIVE';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.inventory_2, color: theme.colorScheme.primary),
        ),
        title: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('$sku  •  $stockQty in stock', style: theme.textTheme.bodySmall),
        trailing: Text(
          '₦${price.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        onTap: () {
          // TODO: navigate to product detail
        },
      ),
    );
  }

  @override
  Widget? buildFAB(BuildContext context) => FloatingActionButton(
        onPressed: () => context.go('/products/new'),
        child: const Icon(Icons.add),
      );
}

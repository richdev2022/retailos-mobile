import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchases')),
      body: const EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'No purchases yet',
        message: 'Create purchase orders to track stock receipts and payables.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New purchase — coming soon')),
          );
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: const EmptyState(
        icon: Icons.business_outlined,
        title: 'No suppliers yet',
        message: 'Add suppliers to track purchases and payables.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add supplier — coming soon')),
          );
        },
        child: const Icon(Icons.add_business),
      ),
    );
  }
}

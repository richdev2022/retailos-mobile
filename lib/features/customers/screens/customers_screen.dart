import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: const EmptyState(
        icon: Icons.people_outline,
        title: 'No customers yet',
        message: 'Add customers to track purchases and credit balances.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add customer — coming soon')),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: const EmptyState(
        icon: Icons.wallet_outlined,
        title: 'No expenses recorded',
        message: 'Track business expenses like rent, utilities, and salaries.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add expense — coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      body: const EmptyState(
        icon: Icons.account_tree_outlined,
        title: 'No branches',
        message: 'Manage multiple business locations and stock transfers.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add branch — coming soon')),
          );
        },
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

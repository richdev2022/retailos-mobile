import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: const EmptyState(
        icon: Icons.people_outline,
        title: 'No staff members',
        message: 'Invite team members to help manage your business.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite staff — coming soon')),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

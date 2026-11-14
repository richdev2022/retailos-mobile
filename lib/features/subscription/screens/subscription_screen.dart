import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Free Plan', style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Your current plan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('You are on the Free plan with 50 products, 1 staff member, and 1 branch. Upgrade to unlock unlimited products, advanced reports, and more.'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upgrade — coming soon')),
                        );
                      },
                      icon: const Icon(Icons.upgrade),
                      label: const Text('Upgrade plan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Available plans', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _PlanCard(name: 'Free', price: '₦0', features: const ['50 products', '1 staff', '1 branch', 'Basic reports']),
          _PlanCard(name: 'Pro', price: '₦15,000/mo', features: const ['Unlimited products', '1 staff', '1 branch', 'Advanced reports', 'Cloud sync'], popular: true),
          _PlanCard(name: 'Business', price: '₦45,000/mo', features: const ['Unlimited products', '5 staff', '1 branch', 'Multi-user permissions']),
          _PlanCard(name: 'Enterprise', price: '₦120,000/mo', features: const ['Unlimited everything', 'Multiple branches', 'Branch analytics']),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.name, required this.price, required this.features, this.popular = false});
  final String name;
  final String price;
  final List<String> features;
  final bool popular;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: popular
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (popular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Popular', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(price, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(f, style: theme.textTheme.bodyMedium),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/business_state.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';

/// Screen shown after login if the user has multiple businesses.
/// Lets them pick which business to activate, or prompts biometric setup.
class SelectBusinessScreen extends ConsumerStatefulWidget {
  const SelectBusinessScreen({super.key});

  @override
  ConsumerState<SelectBusinessScreen> createState() => _SelectBusinessScreenState();
}

class _SelectBusinessScreenState extends ConsumerState<SelectBusinessScreen> {
  @override
  void initState() {
    super.initState();
    // After the screen loads, check if we should prompt biometric
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometricPrompt());
  }

  Future<void> _checkBiometricPrompt() async {
    final bioAvailable = await BiometricService.instance.isAvailable;
    final bioEnabled = await SecureStorage.getBiometricEnabled();
    final hasPrompted = await SecureStorage().readKey('biometric_prompted') == 'true';

    if (bioAvailable && !bioEnabled && !hasPrompted && mounted) {
      await SecureStorage().writeKey('biometric_prompted', 'true');
      _showBiometricPrompt();
    }
  }

  void _showBiometricPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, size: 28),
            SizedBox(width: 8),
            Text('Enable Biometric Login?'),
          ],
        ),
        content: const Text(
          'Would you like to use fingerprint or face ID to log in faster next time? '
          'You can always change this in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              await SecureStorage.setBiometricEnabled(true);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric login enabled! You can use fingerprint next time.')),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bizState = ref.watch(businessProvider);
    final businesses = bizState.memberships;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Business'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              ref.read(businessProvider.notifier).clear();
              if (context.mounted) context.go('/welcome');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: businesses.length + 1, // +1 for "Create new business" button
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index < businesses.length) {
              final m = businesses[index];
              final biz = m;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      biz.name.isNotEmpty ? biz.name[0].toUpperCase() : '?',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(biz.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${m.roleName} • ${biz.currency}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Set active business and save to SecureStorage
                    ref.read(businessProvider.notifier).setActiveBusiness(biz.id);
                    await SecureStorage.setActiveBusinessId(biz.id);
                    if (context.mounted) context.go('/home');
                  },
                ),
              );
            } else {
              // Create new business button
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text('Create new business'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/onboarding/business'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

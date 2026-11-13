import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

/// POS / sales tab — quick cart + checkout entry point.
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point of Sale')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchTile(
                      onTap: () => context.push('/products'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconButton(
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: () => _scan(context),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'Cart is empty',
                message: 'Scan a barcode or pick products to add them to the sale.',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppTheme.lightSurface
                : AppTheme.darkSurface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      MoneyUtils.formatMinor(0, 'NGN'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: 'Checkout',
                icon: Icons.arrow_forward_rounded,
                expand: false,
                onPressed: () => context.push('/pos/checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scan(BuildContext context) {
    // TODO: integrate mobile_scanner (barcode lookup → product lookup endpoint).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanner coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              size: 20,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight),
          const SizedBox(width: 10),
          Text(
            'Search or scan products',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

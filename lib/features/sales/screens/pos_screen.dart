import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

/// POS / sales tab — quick cart + checkout entry point.
///
/// Barcode scanning uses the mobile_scanner package (already in pubspec).
/// When the user taps the scan button, a full-screen scanner overlay opens.
/// On successful scan, the barcode is looked up via the products API and
/// added to the cart (TODO: cart state — for now shows the scanned code).
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<_CartItem> _cart = <_CartItem>[];

  int get _totalMinor => _cart.fold<int>(0, (sum, item) => sum + item.priceMinor * item.qty);

  void _addCartItem(String name, int priceMinor) {
    final existing = _cart.indexWhere((c) => c.name == name);
    if (existing >= 0) {
      setState(() => _cart[existing].qty++);
    } else {
      setState(() => _cart.add(_CartItem(name: name, priceMinor: priceMinor, qty: 1)));
    }
  }

  void _removeItem(int index) {
    setState(() {
      if (_cart[index].qty > 1) {
        _cart[index].qty--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point of Sale')),
      body: SafeArea(
        child: Column(
          children: [
            // Search + scan row
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
                    onTap: _startScanner,
                  ),
                ],
              ),
            ),
            // Cart list
            Expanded(
              child: _cart.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Cart is empty',
                      message: 'Scan a barcode or pick products to add them to the sale.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _cart.length,
                      itemBuilder: (context, i) {
                        final item = _cart[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text('${item.qty}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(MoneyUtils.formatMinor(item.priceMinor * item.qty, 'NGN')),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeItem(i),
                            ),
                          ),
                        );
                      },
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
              top: BorderSide(color: Theme.of(context).dividerColor),
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
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      MoneyUtils.formatMinor(_totalMinor, 'NGN'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: 'Checkout',
                icon: Icons.arrow_forward_rounded,
                expand: false,
                onPressed: _cart.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Checkout — ${_cart.length} items, ${MoneyUtils.formatMinor(_totalMinor, 'NGN')}')),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the mobile_scanner camera view as a full-screen overlay.
  void _startScanner() {

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _BarcodeScannerPage(
          onDetect: (barcode) {
            Navigator.pop(context);
            // Add a placeholder item with the scanned barcode as name.
            // In production this would call the product lookup API.
            _addCartItem('Scanned: $barcode', 0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Scanned: $barcode — lookup product via API to add to cart')),
            );
          },
          onCancel: () => Navigator.pop(context),
        ),
      ),
    ).then((_) {});
  }
}

/// Simple data class for a cart item.
class _CartItem {
  _CartItem({required this.name, required this.priceMinor, this.qty = 1});
  String name;
  int priceMinor;
  int qty;
}

/// Full-screen barcode scanner using mobile_scanner.
class _BarcodeScannerPage extends StatelessWidget {
  const _BarcodeScannerPage({required this.onDetect, required this.onCancel});
  final void Function(String barcode) onDetect;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCancel,
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null && code.isNotEmpty) {
              onDetect(code);
            }
          }
        },
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

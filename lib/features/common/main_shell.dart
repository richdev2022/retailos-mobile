import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell with bottom navigation: Home, Products, POS (center highlighted),
/// Sales, Settings.
///
/// POS is elevated as a prominent center action.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          height: 64,
          padding: EdgeInsets.zero,
          color: theme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _navItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
              _navItem(context, 1, Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
              _posButton(context),
              _navItem(context, 3, Icons.receipt_long_outlined, Icons.receipt_long, 'Sales'),
              _navItem(context, 4, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final theme = Theme.of(context);
    final isActive = navigationShell.currentIndex == index;
    final color = isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: () => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posButton(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = navigationShell.currentIndex == 2;
    return Expanded(
      child: InkWell(
        onTap: () => navigationShell.goBranch(2, initialLocation: isActive),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.point_of_sale, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              'POS',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

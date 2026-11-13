import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// The destinations exposed by the main app shell (bottom navigation).
enum ShellTab { home, products, pos, reports, settings }

extension ShellTabX on ShellTab {
  IconData get icon => switch (this) {
        ShellTab.home => Icons.home_outlined,
        ShellTab.products => Icons.inventory_2_outlined,
        ShellTab.pos => Icons.point_of_sale_outlined,
        ShellTab.reports => Icons.bar_chart_rounded,
        ShellTab.settings => Icons.settings_outlined,
      };

  IconData get activeIcon => switch (this) {
        ShellTab.home => Icons.home_rounded,
        ShellTab.products => Icons.inventory_2_rounded,
        ShellTab.pos => Icons.point_of_sale_rounded,
        ShellTab.reports => Icons.insights_rounded,
        ShellTab.settings => Icons.settings_rounded,
      };

  String get label => switch (this) {
        ShellTab.home => 'Home',
        ShellTab.products => 'Products',
        ShellTab.pos => 'POS',
        ShellTab.reports => 'Reports',
        ShellTab.settings => 'Settings',
      };
}

/// Shell that hosts the bottom navigation bar for the main app screens.
/// The center POS tab is rendered as a highlighted circular action.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({
    super.key,
    required this.shell,
  });

  /// The [StatefulNavigationShell] supplied by [StatefulShellRoute.indexedStack].
  /// It renders the currently-selected branch's navigator.
  final StatefulNavigationShell shell;

  void _goTo(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final tabs = ShellTab.values;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: shell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isLight ? AppTheme.lightSurface : AppTheme.darkSurface,
          border: Border(
            top: BorderSide(
              color: isLight ? AppTheme.lightBorder : AppTheme.darkBorder,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _NavButton(
                  tab: tabs[i],
                  selected: shell.currentIndex == i,
                  isCenter: i == 2,
                  onTap: () => _goTo(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tab,
    required this.selected,
    required this.isCenter,
    required this.onTap,
  });

  final ShellTab tab;
  final bool selected;
  final bool isCenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (isCenter) {
      // Highlighted POS action: a circular emerald button that lifts above the bar.
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    selected ? tab.activeIcon : tab.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final color = selected
        ? AppTheme.primary
        : (isLight ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? tab.activeIcon : tab.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

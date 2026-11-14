import 'package:flutter/material.dart';
import 'package:retailos_mobile/features/common/placeholder_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_state.dart';
import '../state/business_state.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/accept_invitation_screen.dart';
import '../../features/onboarding/screens/create_business_screen.dart';
import '../../features/onboarding/screens/select_business_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/sales/screens/sales_history_screen.dart';
import '../../features/sales/screens/pos_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/suppliers/screens/suppliers_screen.dart';
import '../../features/purchases/screens/purchases_screen.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/reports/screens/generic_report_screen.dart';
import '../../features/staff/screens/staff_screen.dart';
import '../../features/branches/screens/branches_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/common/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final bizState = ref.watch(businessProvider);

  final isAuthenticated = authState.isAuthenticated;
  final hasActiveBusiness = bizState.hasActiveBusiness;

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;

      // Splash screen — always allowed
      if (loc == '/splash') return null;

      // Not authenticated → only allow auth/welcome screens
      if (!isAuthenticated) {
        final isAuthRoute = loc == '/welcome' || loc.startsWith('/auth/');
        return isAuthRoute ? null : '/welcome';
      }

      // Authenticated — allow access to select-business, onboarding, and app routes
      // If user has an active business, redirect away from auth/welcome/select screens
      if (hasActiveBusiness) {
        final isAuthRoute = loc == '/welcome' || loc.startsWith('/auth/') || loc == '/select-business' || loc == '/onboarding/business';
        if (isAuthRoute && loc != '/auth/accept-invitation') {
          return '/home';
        }
        return null;
      }

      // Authenticated but NO active business selected
      // If user has businesses (memberships loaded), go to select-business
      // If no businesses, go to onboarding
      if (bizState.hasBusiness) {
        // User has businesses but hasn't selected one
        final isSelectOrOnboarding = loc == '/select-business' || loc == '/onboarding/business';
        return isSelectOrOnboarding ? null : '/select-business';
      } else {
        // No businesses at all — go to onboarding
        // But allow select-business if they're coming from onboarding skip
        final isOnboarding = loc == '/onboarding/business' || loc == '/select-business';
        return isOnboarding ? null : '/onboarding/business';
      }
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (BuildContext context, GoRouterState state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/auth/accept-invitation',
        builder: (BuildContext context, GoRouterState state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return AcceptInvitationScreen(token: token);
        },
      ),
      GoRoute(
        path: '/onboarding/business',
        builder: (BuildContext context, GoRouterState state) => const CreateBusinessScreen(),
      ),
      GoRoute(
        path: '/select-business',
        builder: (BuildContext context, GoRouterState state) => const SelectBusinessScreen(),
      ),
      // Standalone routes
      GoRoute(path: '/inventory', builder: (c, s) => const InventoryScreen()),
      GoRoute(path: '/customers', builder: (c, s) => const CustomersScreen()),
      GoRoute(path: '/suppliers', builder: (c, s) => const SuppliersScreen()),
      GoRoute(path: '/purchases', builder: (c, s) => const PurchasesScreen()),
      GoRoute(path: '/expenses', builder: (c, s) => const ExpensesScreen()),
      GoRoute(path: '/staff', builder: (c, s) => const StaffScreen()),
      GoRoute(path: '/branches', builder: (c, s) => const BranchesScreen()),
      GoRoute(path: '/subscription', builder: (c, s) => const SubscriptionScreen()),
      GoRoute(path: '/reports/sales', builder: (c, s) => const GenericReportScreen(title: 'Sales Report', endpoint: '/reports/sales')),
      GoRoute(path: '/reports/profit-loss', builder: (c, s) => const GenericReportScreen(title: 'Profit & Loss', endpoint: '/reports/profit-loss')),
      GoRoute(path: '/reports/inventory', builder: (c, s) => const GenericReportScreen(title: 'Inventory Valuation', endpoint: '/reports/inventory')),
      GoRoute(path: '/reports/stock-movement', builder: (c, s) => const GenericReportScreen(title: 'Stock Movements', endpoint: '/reports/inventory')),
      GoRoute(path: '/reports/low-stock', builder: (c, s) => const GenericReportScreen(title: 'Low Stock', endpoint: '/reports/inventory')),
      GoRoute(path: '/reports/expiry', builder: (c, s) => const GenericReportScreen(title: 'Expiry Tracking', endpoint: '/reports/inventory')),
      GoRoute(path: '/reports/product-performance', builder: (c, s) => const GenericReportScreen(title: 'Product Performance', endpoint: '/reports/sales')),
      GoRoute(path: '/reports/cashier', builder: (c, s) => const GenericReportScreen(title: 'Cashier Report', endpoint: '/reports/sales')),
      GoRoute(path: '/reports/customer-credit', builder: (c, s) => const GenericReportScreen(title: 'Customer Credit', endpoint: '/reports/sales')),
      GoRoute(path: '/reports/supplier', builder: (c, s) => const GenericReportScreen(title: 'Supplier Report', endpoint: '/reports/sales')),
      GoRoute(path: '/reports/expenses', builder: (c, s) => const GenericReportScreen(title: 'Expenses Report', endpoint: '/reports/sales')),
      GoRoute(path: '/notifications', builder: (c, s) => const GenericReportScreen(title: 'Notifications', endpoint: '/notifications')),
      // Bottom-nav shell
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (c, s) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/products', builder: (c, s) => const ProductListScreen(), routes: [GoRoute(path: 'new', builder: (c, s) => const ProductListScreen())])]),
          StatefulShellBranch(routes: [GoRoute(path: '/pos', builder: (c, s) => const PosScreen(), routes: [GoRoute(path: 'checkout', builder: (c, s) => const PosScreen()), GoRoute(path: 'receipt/:id', builder: (c, s) => PlaceholderScreen(title: 'Receipt ${s.pathParameters['id']!}'))])]),
          StatefulShellBranch(routes: [GoRoute(path: '/sales', builder: (c, s) => const SalesHistoryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/reports', builder: (c, s) => const ReportsScreen()), GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen())]),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Page not found: ${state.matchedLocation}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.go('/home'), child: const Text('Go home')),
            ],
          ),
        ),
      ),
    ),
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _ref.listen<BusinessState>(businessProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

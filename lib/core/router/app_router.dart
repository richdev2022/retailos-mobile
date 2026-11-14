import 'package:flutter/material.dart';
import 'package:retailos_mobile/features/common/placeholder_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_state.dart';
import '../state/business_state.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/accept_invitation_screen.dart';
import '../../features/onboarding/screens/create_business_screen.dart';
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
    initialLocation: '/welcome',
    debugLogDiagnostics: false,
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final loggingIn = state.matchedLocation == '/welcome' ||
          state.matchedLocation.startsWith('/auth/') ||
          state.matchedLocation == '/onboarding/business';
      if (!isAuthenticated) {
        return loggingIn ? null : '/welcome';
      }
      // Authenticated but no business yet → onboarding
      if (!hasActiveBusiness && state.matchedLocation != '/onboarding/business') {
        return '/onboarding/business';
      }
      // Authenticated + has business + trying to access login/welcome → redirect to home
      if (isAuthenticated && hasActiveBusiness && loggingIn && state.matchedLocation != '/auth/accept-invitation') {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
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
      // Standalone routes (not in bottom nav) — accessible from settings, dashboard, etc.
      GoRoute(
        path: '/inventory',
        builder: (BuildContext context, GoRouterState state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (BuildContext context, GoRouterState state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (BuildContext context, GoRouterState state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: '/purchases',
        builder: (BuildContext context, GoRouterState state) => const PurchasesScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (BuildContext context, GoRouterState state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: '/staff',
        builder: (BuildContext context, GoRouterState state) => const StaffScreen(),
      ),
      GoRoute(
        path: '/branches',
        builder: (BuildContext context, GoRouterState state) => const BranchesScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (BuildContext context, GoRouterState state) => const SubscriptionScreen(),
      ),
      // Report sub-routes (each opens a GenericReportScreen with a title + endpoint)
      GoRoute(
        path: '/reports/sales',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Sales Report', endpoint: '/reports/sales'),
      ),
      GoRoute(
        path: '/reports/profit-loss',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Profit & Loss', endpoint: '/reports/profit-loss'),
      ),
      GoRoute(
        path: '/reports/inventory',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Inventory Valuation', endpoint: '/reports/inventory'),
      ),
      GoRoute(
        path: '/reports/stock-movement',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Stock Movements', endpoint: '/reports/inventory'),
      ),
      GoRoute(
        path: '/reports/low-stock',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Low Stock', endpoint: '/reports/inventory'),
      ),
      GoRoute(
        path: '/reports/expiry',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Expiry Tracking', endpoint: '/reports/inventory'),
      ),
      GoRoute(
        path: '/reports/product-performance',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Product Performance', endpoint: '/reports/sales'),
      ),
      GoRoute(
        path: '/reports/cashier',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Cashier Report', endpoint: '/reports/sales'),
      ),
      GoRoute(
        path: '/reports/customer-credit',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Customer Credit', endpoint: '/reports/sales'),
      ),
      GoRoute(
        path: '/reports/supplier',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Supplier Report', endpoint: '/reports/sales'),
      ),
      GoRoute(
        path: '/reports/expenses',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Expenses Report', endpoint: '/reports/sales'),
      ),
      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) => const GenericReportScreen(title: 'Notifications', endpoint: '/notifications'),
      ),
      // Bottom-nav shell routes
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/products',
                builder: (BuildContext context, GoRouterState state) => const ProductListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'new',
                    builder: (BuildContext context, GoRouterState state) => const ProductListScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/pos',
                builder: (BuildContext context, GoRouterState state) => const PosScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'checkout',
                    builder: (BuildContext context, GoRouterState state) => const PosScreen(),
                  ),
                  GoRoute(
                    path: 'receipt/:id',
                    builder: (BuildContext context, GoRouterState state) =>
                        PlaceholderScreen(title: 'Receipt ${state.pathParameters['id']!}'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/sales',
                builder: (BuildContext context, GoRouterState state) => const SalesHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                builder: (BuildContext context, GoRouterState state) => const ReportsScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
              ),
            ],
          ),
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
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go home'),
              ),
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

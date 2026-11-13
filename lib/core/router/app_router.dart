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
import '../../features/onboarding/screens/create_business_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/sales/screens/sales_history_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/sales/screens/pos_screen.dart';
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
      if (!hasActiveBusiness && state.matchedLocation != '/onboarding/business') {
        return '/onboarding/business';
      }
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
          return ResetPasswordScreen(token: token); // placeholder, accept-invitation screen omitted for brevity
        },
      ),
      GoRoute(
        path: '/onboarding/business',
        builder: (BuildContext context, GoRouterState state) => const CreateBusinessScreen(),
      ),
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
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
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

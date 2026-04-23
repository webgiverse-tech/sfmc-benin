import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/features/auth/screens/login_screen.dart';
import 'package:sfmc_flutter/features/dashboard/screens/dashboard_screen.dart';
import 'package:sfmc_flutter/features/products/screens/inventory_screen.dart';
import 'package:sfmc_flutter/features/products/screens/products_screen.dart';
import 'package:sfmc_flutter/features/orders/screens/orders_screen.dart';
import 'package:sfmc_flutter/features/production/screens/production_screen.dart';
import 'package:sfmc_flutter/features/billing/screens/billing_screen.dart';
import 'package:sfmc_flutter/features/reporting/screens/reporting_screen.dart';
import 'package:sfmc_flutter/features/users/screens/users_screen.dart';
import 'package:sfmc_flutter/features/notifications/screens/notifications_screen.dart';
import 'package:sfmc_flutter/navigation/routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.login,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == Routes.login;

      if (!isLoggedIn && !isLoginRoute) {
        return Routes.login;
      }
      if (isLoggedIn && isLoginRoute) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: Routes.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: Routes.inventory,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: Routes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: Routes.production,
        builder: (context, state) => const ProductionScreen(),
      ),
      GoRoute(
        path: Routes.billing,
        builder: (context, state) => const BillingScreen(),
      ),
      GoRoute(
        path: Routes.reporting,
        builder: (context, state) => const ReportingScreen(),
      ),
      GoRoute(
        path: Routes.users,
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Erreur: ${state.error}'))),
  );
}

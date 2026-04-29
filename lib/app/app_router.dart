import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/retailer_signup_screen.dart';
import '../features/auth/presentation/screens/retailer_verify_code_screen.dart';
import '../features/auth/presentation/screens/retailer_complete_profile_screen.dart';
import '../features/auth/presentation/screens/complete_retailer_profile_screen.dart';

import '../features/dashboard/presentation/screens/retailer_dashboard_screen.dart';
import '../features/supplier_profile/presentation/screens/complete_supplier_profile_screen.dart';

import '../features/supplier/dashboard/presentation/screens/supplier_dashboard_screen.dart';
import '../features/supplier/shared/screens/supplier_coming_soon_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const RetailerSignupScreen(),
      ),

      GoRoute(
        path: '/signup/verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return RetailerVerifyCodeScreen(
            email: extra['email'] as String,
            password: extra['password'] as String,
          );
        },
      ),

      GoRoute(
        path: '/signup/complete-profile',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return RetailerCompleteProfileScreen(
            pendingId: extra['pendingId'] as int,
            email: extra['email'] as String,
            password: extra['password'] as String,
          );
        },
      ),

      GoRoute(
<<<<<<< HEAD
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return ResetPasswordScreen(
            email: extra['email'] as String,
          );
        },
      ),

=======
  path: '/forgot-password',
  builder: (context, state) => const ForgotPasswordScreen(),
),
GoRoute(
  path: '/reset-password',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    return ResetPasswordScreen(
      email: extra['email'] as String,
    );
  },
),
>>>>>>> e2f78cffbebec67edee40f11f0fb6a9a01253a72
      GoRoute(
        path: '/complete-supplier-profile',
        builder: (context, state) => const CompleteSupplierProfileScreen(),
      ),

      GoRoute(
        path: '/complete-retailer-profile',
        builder: (context, state) => const CompleteRetailerProfileScreen(),
      ),

      // =========================
      // SUPPLIER ROUTES
      // =========================

      GoRoute(
        path: '/supplier-dashboard',
        builder: (context, state) => const SupplierDashboardScreen(),
      ),

      GoRoute(
        path: '/supplier-products',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Product Management',
          icon: Icons.inventory_2_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-branches',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Branch Management',
          icon: Icons.store_mall_directory_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-inventory',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Branch Inventory',
          icon: Icons.warehouse_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-orders',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Orders Management',
          icon: Icons.receipt_long_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-promotions',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Promotions',
          icon: Icons.local_offer_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-coupons',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Coupons',
          icon: Icons.sell_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-banners',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Home Banners',
          icon: Icons.image_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-shipping',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Shipping Methods',
          icon: Icons.local_shipping_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-tax',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Tax Configuration',
          icon: Icons.percent_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-settings',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Settings',
          icon: Icons.settings_outlined,
        ),
      ),

      GoRoute(
        path: '/supplier-excel-import',
        builder: (context, state) => const SupplierComingSoonScreen(
          title: 'Import Excel',
          icon: Icons.upload_outlined,
        ),
      ),

      // =========================
      // RETAILER ROUTES
      // =========================

      GoRoute(
        path: '/retailer-dashboard',
        builder: (context, state) => const RetailerDashboardScreen(),
      ),
    ],
  );
}
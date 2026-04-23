import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/retailer_signup_screen.dart';
import '../features/auth/presentation/screens/retailer_verify_code_screen.dart';
import '../features/auth/presentation/screens/retailer_complete_profile_screen.dart';
import '../features/auth/presentation/screens/complete_retailer_profile_screen.dart';
import '../features/dashboard/presentation/screens/retailer_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/supplier_dashboard_screen.dart';
import '../features/supplier_profile/presentation/screens/complete_supplier_profile_screen.dart';

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
      GoRoute(
        path: '/complete-supplier-profile',
        builder: (context, state) => const CompleteSupplierProfileScreen(),
      ),
      GoRoute(
        path: '/complete-retailer-profile',
        builder: (context, state) => const CompleteRetailerProfileScreen(),
      ),
      GoRoute(
        path: '/supplier-dashboard',
        builder: (context, state) => const SupplierDashboardScreen(),
      ),
      GoRoute(
        path: '/retailer-dashboard',
        builder: (context, state) => const RetailerDashboardScreen(),
      ),
    ],
  );
}
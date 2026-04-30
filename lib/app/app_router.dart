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
import '../features/dashboard/presentation/screens/retailer_placeholder_screen.dart';
import '../features/dashboard/presentation/screens/supplier_dashboard_screen.dart';

import '../features/retailer_profile/presentation/screens/retailer_profile_screen.dart';
import '../features/retailer_profile/presentation/screens/edit_retailer_profile_screen.dart';

import '../features/supplier_profile/presentation/screens/complete_supplier_profile_screen.dart';
import '../l10n/app_localizations.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
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
      GoRoute(
        path: '/retailer-profile',
        builder: (context, state) => const RetailerProfileScreen(),
      ),
      GoRoute(
        path: '/retailer-profile/edit',
        builder: (context, state) => const EditRetailerProfileScreen(),
      ),

      GoRoute(
        path: '/retailer-cart',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.cart,
            message: l10n.cartComingSoon,
            icon: Icons.shopping_cart_outlined,
          );
        },
      ),
      GoRoute(
        path: '/retailer-notifications',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.notifications,
            message: l10n.notificationsComingSoon,
            icon: Icons.notifications_none_rounded,
          );
        },
      ),
      GoRoute(
        path: '/retailer-promotions',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.promotions,
            message: l10n.promotionsComingSoon,
            icon: Icons.local_offer_outlined,
          );
        },
      ),
      GoRoute(
        path: '/retailer-top-ranking',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.topRanking,
            message: l10n.topRankingComingSoon,
            icon: Icons.trending_up_rounded,
          );
        },
      ),
      GoRoute(
        path: '/retailer-orders',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.orders,
            message: l10n.ordersComingSoon,
            icon: Icons.receipt_long_outlined,
          );
        },
      ),
      GoRoute(
        path: '/retailer-rfq',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.rfq,
            message: l10n.rfqComingSoon,
            icon: Icons.description_outlined,
          );
        },
      ),
      GoRoute(
        path: '/retailer-ai-assistant',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.aiAssistant,
            message: l10n.aiAssistantComingSoon,
            icon: Icons.auto_awesome,
          );
        },
      ),
      GoRoute(
        path: '/retailer-live-chat',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.liveChat,
            message: l10n.liveChatComingSoon,
            icon: Icons.chat_bubble_outline_rounded,
          );
        },
      ),
      GoRoute(
        path: '/retailer-loyalty',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.loyaltyPoints,
            message: l10n.loyaltyComingSoon,
            icon: Icons.star_border_rounded,
          );
        },
      ),
      GoRoute(
        path: '/retailer-wallet',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.walletBalance,
            message: l10n.walletComingSoon,
            icon: Icons.account_balance_wallet_outlined,
          );
        },
      ),
      GoRoute(
        path: '/retailer-credit',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return RetailerPlaceholderScreen(
            title: l10n.creditBalance,
            message: l10n.creditComingSoon,
            icon: Icons.credit_card_outlined,
          );
        },
      ),
    ],
  );
}

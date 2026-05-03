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

import '../features/supplier/products/presentation/screens/product_management_screen.dart';
import '../features/supplier/products/presentation/screens/add_product_screen.dart';
import '../features/supplier/products/domain/entities/product_entity.dart';

import '../features/supplier/branches/domain/entities/branch_entity.dart';
import '../features/supplier/branches/presentation/screens/branch_management_screen.dart';
import '../features/supplier/branches/presentation/screens/add_branch_screen.dart';
import '../features/supplier/branches/presentation/screens/branch_inventory_screen.dart';

import '../features/supplier/promotions/presentation/screens/promotions_screen.dart';
import '../features/supplier/promotions/presentation/screens/create_promotion_screen.dart';
import '../features/supplier/promotions/domain/entities/promotion_entity.dart';

import '../features/supplier/coupons/presentation/screens/coupons_screen.dart';
import '../features/supplier/coupons/presentation/screens/create_coupon_screen.dart';
import '../features/supplier/coupons/domain/entities/coupon_entity.dart';

import '../features/supplier/banners/presentation/screens/banners_screen.dart';
import '../features/supplier/banners/presentation/screens/create_banner_screen.dart';
import '../features/supplier/banners/domain/entities/banner_entity.dart';

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
        path: '/supplier-products',
        builder: (context, state) => const ProductManagementScreen(),
      ),

      GoRoute(
        path: '/supplier-products/add',
        builder: (context, state) => const AddProductScreen(),
      ),

      GoRoute(
        path: '/supplier-products/edit',
        builder: (context, state) {
          final product = state.extra as ProductEntity;

          return AddProductScreen(
            productToEdit: product,
          );
        },
      ),

      GoRoute(
        path: '/supplier-branches',
        builder: (context, state) => const BranchManagementScreen(),
      ),

      GoRoute(
        path: '/supplier-branches/add',
        builder: (context, state) => const AddBranchScreen(),
      ),

      GoRoute(
        path: '/supplier-branches/edit',
        builder: (context, state) {
          final branch = state.extra as BranchEntity;

          return AddBranchScreen(
            branchToEdit: branch,
          );
        },
      ),

      GoRoute(
        path: '/supplier-branches/inventory',
        builder: (context, state) {
          final branch = state.extra as BranchEntity;

          return BranchInventoryScreen(
            branch: branch,
          );
        },
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
        builder: (context, state) => const PromotionsScreen(),
      ),

      GoRoute(
        path: '/supplier-promotions/create',
        builder: (context, state) => const CreatePromotionScreen(),
      ),

      GoRoute(
        path: '/supplier-promotions/edit',
        builder: (context, state) {
          final promotion = state.extra as PromotionEntity;

          return CreatePromotionScreen(
            promotion: promotion,
          );
        },
      ),

      GoRoute(
        path: '/supplier-coupons',
        builder: (context, state) => const CouponsScreen(),
      ),

      GoRoute(
        path: '/supplier-coupons/create',
        builder: (context, state) => const CreateCouponScreen(),
      ),

      GoRoute(
        path: '/supplier-coupons/edit',
        builder: (context, state) {
          final coupon = state.extra as CouponEntity;

          return CreateCouponScreen(
            coupon: coupon,
          );
        },
      ),

      GoRoute(
        path: '/supplier-banners',
        builder: (context, state) => const BannersScreen(),
      ),

      GoRoute(
        path: '/supplier-banners/create',
        builder: (context, state) => const CreateBannerScreen(),
      ),

      GoRoute(
        path: '/supplier-banners/edit',
        builder: (context, state) {
          final banner = state.extra as BannerEntity;

          return CreateBannerScreen(
            banner: banner,
          );
        },
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

      GoRoute(
        path: '/retailer-dashboard',
        builder: (context, state) => const RetailerDashboardScreen(),
      ),
    ],
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/language_selector.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_home_model.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import '../widgets/categories_grid_section.dart';
import '../widgets/featured_products_section.dart';
import '../widgets/group_delivery_card.dart';
import '../widgets/home_banner_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/retailer_home_header.dart';
import '../widgets/retailer_search_bar.dart';

class RetailerDashboardScreen extends StatelessWidget {
  const RetailerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>()..loadHome(),
      child: const _RetailerDashboardView(),
    );
  }
}

class _RetailerDashboardView extends StatefulWidget {
  const _RetailerDashboardView();

  @override
  State<_RetailerDashboardView> createState() => _RetailerDashboardViewState();
}

class _RetailerDashboardViewState extends State<_RetailerDashboardView> {
  late final TextEditingController _searchController;
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(HomeProductModel product) {
    context.read<RetailerHomeCubit>().addToCart(product: product);
  }

  void _goToBottomTab(int index) {
    if (index == _selectedBottomIndex && index == 0) return;

    setState(() => _selectedBottomIndex = index);

    switch (index) {
      case 0:
        context.go('/retailer-dashboard');
        break;
      case 1:
        context.push('/retailer-top-ranking');
        break;
      case 2:
        context.push('/retailer-orders');
        break;
      case 3:
        context.push('/retailer-rfq');
        break;
      case 4:
        context.go('/retailer-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RetailerHomeCubit, RetailerHomeState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RetailerHomeCubit>().clearMessages();
          return;
        }

        if (state.successMessage == 'PRODUCT_ADDED_TO_CART') {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.productAddedToCart)),
          );
          context.read<RetailerHomeCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              context.l10n.retailerDashboard,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: LanguageSelector(),
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RetailerHomeState state) {
    if (state.isLoading && state.home == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (state.home == null) {
      return _ErrorView(
        onRetry: () => context.read<RetailerHomeCubit>().loadHome(),
      );
    }

    final home = state.home!;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<RetailerHomeCubit>().loadHome(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.screenHorizontalPadding,
          8,
          AppThemeTokens.screenHorizontalPadding,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RetailerHomeHeader(
              welcomeName: home.welcomeName,
              notificationCount: home.unreadNotificationsCount,
              cartCount: home.cartItemsCount,
              onNotificationsTap: () => context.push('/retailer-notifications'),
              onCartTap: () async {
                await context.push('/retailer-cart');
                if (!context.mounted) return;
                context.read<RetailerHomeCubit>().loadHome();
              },
            ),
            const SizedBox(height: 18),
            RetailerSearchBar(controller: _searchController, onChanged: (_) {}),
            const SizedBox(height: 18),
            HomeBannerSection(banners: home.banners),
            const SizedBox(height: 18),
            GroupDeliveryCard(groupDelivery: home.groupDelivery),
            const SizedBox(height: 18),
            QuickActionsSection(actions: home.quickActions),
            const SizedBox(height: 24),
            CategoriesGridSection(categories: home.categories),
            const SizedBox(height: 24),
            FeaturedProductsSection(
              products: home.featuredProducts,
              addingProductId: state.addingProductId,
              onAddToCart: _addToCart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final l10n = context.l10n;

    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: _goToBottomTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: AppThemeTokens.textSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up_rounded),
          label: l10n.topRanking,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          label: l10n.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.description_outlined),
          label: l10n.rfq,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          label: l10n.profile,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppThemeTokens.error,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.couldNotLoadRetailerHome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.checkConnectionTryAgain,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.retry,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

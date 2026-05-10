import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_bloc.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_event.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_state.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/widgets/supplier_dashboard_stat_card.dart';
import '../../../shared/widgets/supplier_quick_action_card.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierDashboardBloc>(
      create: (_) =>
          sl<SupplierDashboardBloc>()..add(const SupplierDashboardStarted()),
      child: const _SupplierDashboardView(),
    );
  }
}

class _SupplierDashboardView extends StatelessWidget {
  const _SupplierDashboardView();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<SupplierDashboardBloc, SupplierDashboardState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: Scaffold(
        backgroundColor: AppThemeTokens.background,
        drawer: const SupplierAppDrawer(),
        appBar: AppBar(
          backgroundColor: AppThemeTokens.background,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Menu',
                icon: Icon(
                  Icons.menu,
                  size: 32,
                  color: primary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          title: Text(
            'Supplier Dashboard',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Supplier Profile',
              onPressed: () => context.go('/supplier-profile'),
              icon: Icon(
                Icons.person_outline,
                color: primary,
                size: 27,
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                context.read<SupplierDashboardBloc>().add(
                      const SupplierDashboardRefreshed(),
                    );
              },
              icon: Icon(
                Icons.refresh_outlined,
                color: primary,
                size: 27,
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => context.go('/supplier-settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: primary,
                size: 27,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<SupplierDashboardBloc, SupplierDashboardState>(
          builder: (context, state) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SupplierDashboardBloc>().add(
                        const SupplierDashboardRefreshed(),
                      );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppThemeTokens.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.isLoading)
                        const _DashboardLoadingCard()
                      else
                        _buildStatsGrid(state),
                      const SizedBox(height: 24),
                      _buildFinancialSummary(context, state),
                      const SizedBox(height: 24),
                      const Text(
                        'Low Stock Alerts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLowStockAlerts(state),
                      const SizedBox(height: 28),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(SupplierDashboardState state) {
    final cards = [
      SupplierDashboardStatCard(
        title: 'Pending Orders',
        value: state.pendingOrders.toString(),
        icon: Icons.receipt_long_outlined,
        iconColor: const Color(0xFFF97316),
        iconBackgroundColor: const Color(0xFFFFEDD5),
      ),
      SupplierDashboardStatCard(
        title: 'Active Orders',
        value: state.activeOrders.toString(),
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBackgroundColor: const Color(0xFFDBEAFE),
      ),
      SupplierDashboardStatCard(
        title: 'Shipped Orders',
        value: state.shippedOrders.toString(),
        icon: Icons.local_shipping_outlined,
        iconColor: const Color(0xFFA855F7),
        iconBackgroundColor: const Color(0xFFF3E8FF),
      ),
      SupplierDashboardStatCard(
        title: 'Completed Orders',
        value: state.completedOrders.toString(),
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF16A34A),
        iconBackgroundColor: const Color(0xFFDCFCE7),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildFinancialSummary(
    BuildContext context,
    SupplierDashboardState state,
  ) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  value: _formatMoney(state.todaysSales),
                  label: "Today's Sales",
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: _formatMoney(state.monthlyRevenue),
                  label: 'Monthly Revenue',
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: state.totalOrdersToday.toString(),
                  label: 'Orders Today',
                  valueColor: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlerts(SupplierDashboardState state) {
    if (state.lowStockAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'No low stock alerts',
              style: TextStyle(
                fontSize: 16,
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: state.lowStockAlerts.map((alert) {
        return _LowStockAlertCard(alert: alert);
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      SupplierQuickActionCard(
        title: 'Add Product',
        icon: Icons.add,
        onTap: () => context.push('/supplier-products/add'),
      ),
      SupplierQuickActionCard(
        title: 'Create Promotion',
        icon: Icons.local_offer_outlined,
        onTap: () => context.go('/supplier-promotions/create'),
      ),
      SupplierQuickActionCard(
        title: 'Manage Branches',
        icon: Icons.location_on_outlined,
        onTap: () => context.go('/supplier-branches'),
      ),
      SupplierQuickActionCard(
        title: 'Shipping Methods',
        icon: Icons.local_shipping_outlined,
        onTap: () => context.go('/supplier-shipping'),
      ),
      SupplierQuickActionCard(
        title: 'Configure Taxes',
        icon: Icons.attach_money,
        onTap: () => context.go('/supplier-tax'),
      ),
      SupplierQuickActionCard(
        title: 'Import Excel',
        icon: Icons.upload_file_outlined,
        onTap: () => context.go('/supplier-excel-import'),
      ),
      SupplierQuickActionCard(
        title: 'Home Banners',
        icon: Icons.image_outlined,
        onTap: () => context.go('/supplier-banners/create'),
      ),
      SupplierQuickActionCard(
        title: 'Coupons',
        icon: Icons.sell_outlined,
        onTap: () => context.go('/supplier-coupons/create'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) => actions[index],
    );
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              'Loading dashboard data...',
              style: TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _FinancialItem({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppThemeTokens.textSecondary,
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LowStockAlertCard extends StatelessWidget {
  final dynamic alert;

  const _LowStockAlertCard({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final productName = _readProductName();
    final branchName = _readBranchName();
    final currentStock = _readCurrentStock();
    final minimumStock = _readMinimumStock();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branchName.isEmpty ? 'Low stock item' : branchName,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current stock: $currentStock | Minimum: $minimumStock',
                  style: const TextStyle(
                    color: AppThemeTokens.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _readProductName() {
    try {
      final value = alert.productName;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final value = alert.name;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return 'Low stock product';
  }

  String _readBranchName() {
    try {
      final value = alert.branchName;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final value = alert.warehouseName;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return '';
  }

  String _readCurrentStock() {
    try {
      final value = alert.currentStock;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final value = alert.stockQuantity;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final value = alert.quantity;
      if (value != null) return value.toString();
    } catch (_) {}

    return '0';
  }

  String _readMinimumStock() {
    try {
      final value = alert.minimumStock;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final value = alert.minimumStockLevel;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final value = alert.threshold;
      if (value != null) return value.toString();
    } catch (_) {}

    return '0';
  }
}
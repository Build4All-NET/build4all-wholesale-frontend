import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/utils/supplier_formatters.dart';
import '../../../../../injection_container.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_bloc.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_event.dart';
import '../bloc/supplier_dashboard/supplier_dashboard_state.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/widgets/supplier_dashboard_stat_card.dart';
import '../../../shared/widgets/supplier_quick_action_card.dart';

class SupplierDashboardScreen extends StatelessWidget {
  SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierDashboardBloc>(
      create: (_) =>
          sl<SupplierDashboardBloc>()..add(SupplierDashboardStarted()),
      child: _SupplierDashboardView(),
    );
  }
}

class _SupplierDashboardView extends StatelessWidget {
  _SupplierDashboardView();

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
        drawer: SupplierAppDrawer(),
        appBar: AppBar(
          backgroundColor: AppThemeTokens.background,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                tooltip: context.l10n.supplierDashboardMenuTooltip,
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
            context.l10n.supplierDashboardTitle,
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
              tooltip: context.l10n.supplierProfileTitle,
              onPressed: () => context.go('/supplier-profile'),
              icon: Icon(
                Icons.person_outline,
                color: primary,
                size: 27,
              ),
            ),
            IconButton(
              tooltip: context.l10n.supplierProfileRefreshTooltip,
              onPressed: () {
                context.read<SupplierDashboardBloc>().add(
                      SupplierDashboardRefreshed(),
                    );
              },
              icon: Icon(
                Icons.refresh_outlined,
                color: primary,
                size: 27,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<SupplierDashboardBloc, SupplierDashboardState>(
          builder: (context, state) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SupplierDashboardBloc>().add(
                        SupplierDashboardRefreshed(),
                      );
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(
                    AppThemeTokens.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.isLoading)
                        _DashboardLoadingCard()
                      else
                        _buildStatsGrid(context, state),
                      SizedBox(height: 24),
                      _buildFinancialSummary(context, state),
                      SizedBox(height: 24),
                      Text(
                        context.l10n.supplierDashboardLowStockAlerts,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildLowStockAlerts(context, state),
                      SizedBox(height: 28),
                      Text(
                        context.l10n.supplierDashboardQuickActions,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
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

  Widget _buildStatsGrid(BuildContext context, SupplierDashboardState state) {
    final cards = [
      SupplierDashboardStatCard(
        title: context.l10n.supplierPendingOrders,
        value: state.pendingOrders.toString(),
        icon: Icons.receipt_long_outlined,
        iconColor: Color(0xFFF97316),
        iconBackgroundColor: Color(0xFFFFEDD5),
      ),
      SupplierDashboardStatCard(
        title: context.l10n.supplierActiveOrders,
        value: state.activeOrders.toString(),
        icon: Icons.inventory_2_outlined,
        iconColor: Color(0xFF2563EB),
        iconBackgroundColor: Color(0xFFDBEAFE),
      ),
      SupplierDashboardStatCard(
        title: context.l10n.supplierShippedOrders,
        value: state.shippedOrders.toString(),
        icon: Icons.local_shipping_outlined,
        iconColor: Color(0xFFA855F7),
        iconBackgroundColor: Color(0xFFF3E8FF),
      ),
      SupplierDashboardStatCard(
        title: context.l10n.supplierCompletedOrders,
        value: state.completedOrders.toString(),
        icon: Icons.check_circle_outline,
        iconColor: Color(0xFF16A34A),
        iconBackgroundColor: Color(0xFFDCFCE7),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.supplierFinancialSummary,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  value: formatSupplierCurrency(context, state.todaysSales),
                  label: context.l10n.supplierTodaySales,
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: formatSupplierCurrency(context, state.monthlyRevenue),
                  label: context.l10n.supplierMonthlyRevenue,
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: state.totalOrdersToday.toString(),
                  label: context.l10n.supplierOrdersToday,
                  valueColor: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlerts(BuildContext context, SupplierDashboardState state) {
    if (state.lowStockAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              context.l10n.supplierNoLowStockAlerts,
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
        title: context.l10n.supplierAddProduct,
        icon: Icons.add,
        onTap: () => context.push('/supplier-products/add'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierCreatePromotion,
        icon: Icons.local_offer_outlined,
        onTap: () => context.go('/supplier-promotions/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierManageBranches,
        icon: Icons.location_on_outlined,
        onTap: () => context.go('/supplier-branches'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerShippingMethods,
        icon: Icons.local_shipping_outlined,
        onTap: () => context.go('/supplier-shipping/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierConfigureTaxes,
        icon: Icons.percent_outlined,
        onTap: () => context.go('/supplier-tax-rules/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierImportExcel,
        icon: Icons.upload_file_outlined,
        onTap: () => context.go('/supplier-excel-import'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerHomeBanners,
        icon: Icons.image_outlined,
        onTap: () => context.go('/supplier-banners/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerCoupons,
        icon: Icons.sell_outlined,
        onTap: () => context.go('/supplier-coupons/create'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) => actions[index],
    );
  }

}

class _DashboardLoadingCard extends StatelessWidget {
  _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text(
              context.l10n.supplierLoadingDashboardData,
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

  _FinancialItem({
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
        SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
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

  _LowStockAlertCard({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final productName = _readProductName(context);
    final branchName = _readBranchName();
    final currentStock = _readCurrentStock();
    final minimumStock = _readMinimumStock();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
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
            decoration: BoxDecoration(
              color: Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  branchName.isEmpty ? context.l10n.supplierLowStockItem : branchName,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  context.l10n.supplierCurrentMinimumStock(currentStock, minimumStock),
                  style: TextStyle(
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

  String _readProductName(BuildContext context) {
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

    return context.l10n.supplierLowStockProduct;
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

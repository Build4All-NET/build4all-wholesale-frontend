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
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

String _paymentMethodsDashboardLabel(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;
  if (languageCode == 'ar') return 'طرق الدفع';
  if (languageCode == 'fr') return 'Méthodes de paiement';
  return 'Payment Methods';
}

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

class _SupplierDashboardView extends StatefulWidget {
  _SupplierDashboardView();

  @override
  State<_SupplierDashboardView> createState() => _SupplierDashboardViewState();
}

class _SupplierDashboardViewState extends State<_SupplierDashboardView> {
  static const int _lowStockPreviewCount = 3;
  bool _showAllLowStockAlerts = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<SupplierDashboardBloc, SupplierDashboardState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        AppToast.error(context, state.errorMessage!);
      },
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: Scaffold(
          backgroundColor: AppThemeTokens.background,
          drawer: SupplierAppDrawer(),
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            surfaceTintColor: AppThemeTokens.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  tooltip: context.l10n.supplierDashboardMenuTooltip,
                  icon: Icon(
                    Icons.menu_rounded,
                    size: 31,
                    color: AppThemeTokens.textPrimary,
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
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                tooltip: context.l10n.notifications,
                onPressed: () => context.push('/supplier-notifications'),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: AppThemeTokens.textPrimary,
                      size: 29,
                    ),
                    Positioned(
                      right: -4,
                      top: -5,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    padding: EdgeInsets.fromLTRB(
                      AppThemeTokens.screenHorizontalPadding,
                      12,
                      AppThemeTokens.screenHorizontalPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WelcomeHeaderCard(
                          supplierName: state.supplierDisplayName,
                        ),
                        SizedBox(height: 18),
                        if (state.isLoading)
                          _DashboardLoadingCard()
                        else
                          _buildStatsGrid(context, state),
                        SizedBox(height: 18),
                        _buildFinancialSummary(context, state),
                        SizedBox(height: 24),
                        _SectionTitle(
                          title: context.l10n.supplierDashboardQuickActions,
                        ),
                        SizedBox(height: 12),
                        _buildQuickActions(context),
                        SizedBox(height: 24),
                        _SectionTitle(
                          title: context.l10n.supplierDashboardLowStockAlerts,
                          trailingText: context.l10n.viewAll,
                          onTrailingTap: () => context.go('/supplier-products'),
                        ),
                        SizedBox(height: 12),
                        _buildLowStockAlerts(
                          context,
                          state,
                          showAllLowStockAlerts: _showAllLowStockAlerts,
                          onToggleLowStockAlerts: () {
                            setState(() {
                              _showAllLowStockAlerts = !_showAllLowStockAlerts;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.05,
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
      padding: EdgeInsets.fromLTRB(15, 15, 15, 14),
      decoration: _dashboardCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.supplierFinancialSummary,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              _SoftIconBadge(
                icon: Icons.trending_up_rounded,
                iconColor: primary,
                backgroundColor: primary.withOpacity(0.10),
                size: 36,
                iconSize: 19,
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  value: formatSupplierCurrency(context, state.todaysSales),
                  label: context.l10n.supplierTodaySales,
                  valueColor: primary,
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _FinancialItem(
                  value: formatSupplierCurrency(context, state.monthlyRevenue),
                  label: context.l10n.supplierMonthlyRevenue,
                  valueColor: primary,
                ),
              ),
              _VerticalDivider(),
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

  Widget _buildLowStockAlerts(
    BuildContext context,
    SupplierDashboardState state, {
    required bool showAllLowStockAlerts,
    required VoidCallback onToggleLowStockAlerts,
  }) {
    if (state.lowStockAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18),
        decoration: _dashboardCardDecoration(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              context.l10n.supplierNoLowStockAlerts,
              style: TextStyle(
                fontSize: 15,
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final alerts = state.lowStockAlerts;
    final hasMoreAlerts = alerts.length > _lowStockPreviewCount;
    final visibleAlerts = showAllLowStockAlerts || !hasMoreAlerts
        ? alerts
        : alerts.take(_lowStockPreviewCount).toList();
    final remainingAlerts = alerts.length - _lowStockPreviewCount;

    return Column(
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            children: visibleAlerts.map((alert) {
              return _LowStockAlertCard(alert: alert);
            }).toList(),
          ),
        ),
        if (hasMoreAlerts)
          _LowStockAlertsToggle(
            isExpanded: showAllLowStockAlerts,
            hiddenCount: remainingAlerts,
            onTap: onToggleLowStockAlerts,
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      SupplierQuickActionCard(
        title: context.l10n.supplierAddProduct,
        icon: Icons.add_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/supplier-products/add'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierCreatePromotion,
        icon: Icons.local_offer_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-promotions/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierManageBranches,
        icon: Icons.location_on_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-branches'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerShippingMethods,
        icon: Icons.local_shipping_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-shipping/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierConfigureTaxes,
        icon: Icons.attach_money_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-tax-rules/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierImportExcel,
        icon: Icons.upload_file_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-excel-import'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerHomeBanners,
        icon: Icons.image_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-banners/create'),
      ),
      SupplierQuickActionCard(
        title: context.l10n.supplierDrawerCoupons,
        icon: Icons.confirmation_number_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-coupons/create'),
      ),
      SupplierQuickActionCard(
        title: _paymentMethodsDashboardLabel(context),
        icon: Icons.account_balance_wallet_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/supplier-payment-methods'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.75,
      ),
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _WelcomeHeaderCard extends StatelessWidget {
  final String supplierName;

  _WelcomeHeaderCard({required this.supplierName});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final name = supplierName.trim().isEmpty ? 'Supplier' : supplierName.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Color(0xFFF4D7E5)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primary.withOpacity(0.11),
            Colors.white,
            primary.withOpacity(0.06),
          ],
        ),
      ),
      child: Row(
        children: [
          _SoftIconBadge(
            icon: Icons.storefront_rounded,
            iconColor: primary,
            backgroundColor: primary.withOpacity(0.14),
            size: 46,
            iconSize: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.welcomeBack}, $name!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  context.l10n.supplierDashboardOverviewSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  _SectionTitle({required this.title, this.trailingText, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ),
        if (trailingText != null)
          InkWell(
            onTap: onTrailingTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                trailingText!,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
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
      decoration: _dashboardCardDecoration(),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontSize: 12.5,
            height: 1.22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LowStockAlertsToggle extends StatelessWidget {
  final bool isExpanded;
  final int hiddenCount;
  final VoidCallback onTap;

  _LowStockAlertsToggle({
    required this.isExpanded,
    required this.hiddenCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: primary.withOpacity(0.14)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded
                      ? 'Show fewer low-stock alerts'
                      : 'Show more low-stock alerts ($hiddenCount hidden)',
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: primary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LowStockAlertCard extends StatelessWidget {
  final dynamic alert;

  _LowStockAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final productName = _readProductName(context);
    final branchName = _readBranchName();
    final currentStock = _readCurrentStock();
    final minimumStock = _readMinimumStock();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _dashboardCardDecoration(),
      child: Row(
        children: [
          _SoftIconBadge(
            icon: Icons.warning_amber_rounded,
            iconColor: Color(0xFFF97316),
            backgroundColor: Color(0xFFFFEDD5),
            size: 50,
            iconSize: 27,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  branchName.isEmpty
                      ? context.l10n.supplierLowStockItem
                      : branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 118),
            child: Text(
              context.l10n.supplierCurrentMinimumStock(
                currentStock,
                minimumStock,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppThemeTokens.error,
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
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

class _SoftIconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  _SoftIconBadge({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2.6),
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: AppThemeTokens.border);
  }
}

BoxDecoration _dashboardCardDecoration() {
  return BoxDecoration(
    color: AppThemeTokens.surface,
    borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
    border: Border.all(color: AppThemeTokens.border),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF0F172A).withOpacity(0.04),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );
}

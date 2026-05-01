import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/widgets/supplier_dashboard_stat_card.dart';
import '../../../shared/widgets/supplier_quick_action_card.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 32),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Supplier Dashboard',
          style: TextStyle(
            color: primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/supplier-settings'),
            icon: const Icon(Icons.settings_outlined, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildFinancialSummary(context),
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
              _buildLowStockAlerts(),
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
  }

  Widget _buildStatsGrid() {
    final cards = [
      const SupplierDashboardStatCard(
        title: 'Pending Orders',
        value: '0',
        icon: Icons.inventory_2_outlined,
        iconColor: Color(0xFFF97316),
        iconBackgroundColor: Color(0xFFFFEDD5),
      ),
      const SupplierDashboardStatCard(
        title: 'Preparing Orders',
        value: '0',
        icon: Icons.local_shipping_outlined,
        iconColor: Color(0xFF2563EB),
        iconBackgroundColor: Color(0xFFDBEAFE),
      ),
      const SupplierDashboardStatCard(
        title: 'Shipped Orders',
        value: '0',
        icon: Icons.fire_truck_outlined,
        iconColor: Color(0xFFA855F7),
        iconBackgroundColor: Color(0xFFF3E8FF),
      ),
      const SupplierDashboardStatCard(
        title: 'Completed Orders',
        value: '0',
        icon: Icons.check_circle_outline,
        iconColor: Color(0xFF16A34A),
        iconBackgroundColor: Color(0xFFDCFCE7),
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

  Widget _buildFinancialSummary(BuildContext context) {
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
                  value: '\$0',
                  label: "Today's Sales",
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: '\$0',
                  label: 'Monthly Revenue',
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: '0',
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

  Widget _buildLowStockAlerts() {
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
      onTap: () => context.go('/supplier-promotions'),
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
      icon: Icons.upload_outlined,
      onTap: () => context.go('/supplier-excel-import'),
    ),
    SupplierQuickActionCard(
      title: 'Home Banners',
      icon: Icons.image_outlined,
      onTap: () => context.go('/supplier-banners'),
    ),
    SupplierQuickActionCard(
      title: 'Coupons',
      icon: Icons.sell_outlined,
      onTap: () => context.go('/supplier-coupons'),
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
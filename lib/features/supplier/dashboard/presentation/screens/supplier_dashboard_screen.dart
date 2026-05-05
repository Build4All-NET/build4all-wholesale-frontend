import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../orders/data/repositories/supplier_order_repository_impl.dart';
import '../../../orders/domain/entities/supplier_order_entity.dart';
import '../../../orders/domain/repositories/supplier_order_repository.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/widgets/supplier_dashboard_stat_card.dart';
import '../../../shared/widgets/supplier_quick_action_card.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final SupplierOrderRepository orderRepository =
        SupplierOrderRepositoryImpl();

    final pendingOrders =
        orderRepository.countByStatus(SupplierOrderStatus.pending);
    final acceptedOrders =
        orderRepository.countByStatus(SupplierOrderStatus.accepted);
    final preparingOrders =
        orderRepository.countByStatus(SupplierOrderStatus.preparing);
    final shippedOrders =
        orderRepository.countByStatus(SupplierOrderStatus.shipped);
    final completedOrders =
        orderRepository.countByStatus(SupplierOrderStatus.delivered);

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
              _buildStatsGrid(
                pendingOrders: pendingOrders,
                activeOrders: acceptedOrders + preparingOrders,
                shippedOrders: shippedOrders,
                completedOrders: completedOrders,
              ),
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

  Widget _buildStatsGrid({
    required int pendingOrders,
    required int activeOrders,
    required int shippedOrders,
    required int completedOrders,
  }) {
    final cards = [
      SupplierDashboardStatCard(
        title: 'Pending Orders',
        value: pendingOrders.toString(),
        icon: Icons.receipt_long_outlined,
        iconColor: const Color(0xFFF97316),
        iconBackgroundColor: const Color(0xFFFFEDD5),
      ),
      SupplierDashboardStatCard(
        title: 'Active Orders',
        value: activeOrders.toString(),
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBackgroundColor: const Color(0xFFDBEAFE),
      ),
      SupplierDashboardStatCard(
        title: 'Shipped Orders',
        value: shippedOrders.toString(),
        icon: Icons.local_shipping_outlined,
        iconColor: const Color(0xFFA855F7),
        iconBackgroundColor: const Color(0xFFF3E8FF),
      ),
      SupplierDashboardStatCard(
        title: 'Completed Orders',
        value: completedOrders.toString(),
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

  Widget _buildFinancialSummary(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final SupplierOrderRepository orderRepository =
        SupplierOrderRepositoryImpl();

    final orders = orderRepository.getCurrentOrders();

    final deliveredOrders = orders.where(
      (order) => order.status == SupplierOrderStatus.delivered,
    );

    final totalDeliveredRevenue = deliveredOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    final totalOrdersToday = orders.where((order) {
      final now = DateTime.now();

      return order.orderDate.year == now.year &&
          order.orderDate.month == now.month &&
          order.orderDate.day == now.day;
    }).length;

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
                  value: '\$${totalDeliveredRevenue.toStringAsFixed(2)}',
                  label: 'Delivered Sales',
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: '\$${totalDeliveredRevenue.toStringAsFixed(2)}',
                  label: 'Monthly Revenue',
                  valueColor: primary,
                ),
              ),
              Expanded(
                child: _FinancialItem(
                  value: totalOrdersToday.toString(),
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
        title: 'Manage Orders',
        icon: Icons.receipt_long_outlined,
        onTap: () => context.go('/supplier-orders'),
      ),
      SupplierQuickActionCard(
        title: 'Manage Branches',
        icon: Icons.location_on_outlined,
        onTap: () => context.go('/supplier-branches'),
      ),
      SupplierQuickActionCard(
        title: 'Create Promotion',
        icon: Icons.local_offer_outlined,
        onTap: () => context.go('/supplier-promotions/create'),
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
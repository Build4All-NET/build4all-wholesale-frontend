import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../bloc/supplier_orders/supplier_orders_bloc.dart';
import '../bloc/supplier_orders/supplier_orders_event.dart';
import '../bloc/supplier_orders/supplier_orders_state.dart';
import '../widgets/supplier_order_card.dart';

class SupplierOrdersScreen extends StatelessWidget {
  const SupplierOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierOrdersBloc>(
      create: (_) => sl<SupplierOrdersBloc>()..add(const SupplierOrdersStarted()),
      child: const _SupplierOrdersView(),
    );
  }
}

class _SupplierOrdersView extends StatefulWidget {
  const _SupplierOrdersView();

  @override
  State<_SupplierOrdersView> createState() => _SupplierOrdersViewState();
}

class _SupplierOrdersViewState extends State<_SupplierOrdersView> {
  final TextEditingController _searchController = TextEditingController();

  final List<SupplierOrderStatus> _statuses = const [
    SupplierOrderStatus.pending,
    SupplierOrderStatus.accepted,
    SupplierOrderStatus.preparing,
    SupplierOrderStatus.shipped,
    SupplierOrderStatus.delivered,
    SupplierOrderStatus.cancelled,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToDetails(
    BuildContext context,
    SupplierOrderEntity order,
  ) async {
    final result = await context.push<bool>(
      '/supplier-orders/details',
      extra: order,
    );

    if (!context.mounted) return;

    if (result == true) {
      context.read<SupplierOrdersBloc>().add(const SupplierOrdersRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<SupplierOrdersBloc, SupplierOrdersState>(
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
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              );
            },
          ),
          title: Text(
            'Orders Management',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: primary,
              fontSize: 22,
            ),
          ),
        ),
        body: BlocBuilder<SupplierOrdersBloc, SupplierOrdersState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<SupplierOrdersBloc>().add(
                            SupplierOrdersSearchChanged(value),
                          );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search orders, retailers...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppThemeTokens.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppThemeTokens.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppThemeTokens.radiusSmall,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _StatusFilterChip(
                        label: 'All',
                        count: null,
                        isSelected: state.selectedStatus == null,
                        onTap: () {
                          context.read<SupplierOrdersBloc>().add(
                                const SupplierOrdersStatusFilterChanged(null),
                              );
                        },
                      ),
                      ..._statuses.map(
                        (status) => _StatusFilterChip(
                          label: _statusLabel(status),
                          count: state.countForStatus(status),
                          isSelected: state.selectedStatus == status,
                          onTap: () {
                            context.read<SupplierOrdersBloc>().add(
                                  SupplierOrdersStatusFilterChanged(status),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppThemeTokens.border),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.orders.isEmpty
                          ? const _EmptyOrdersView()
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<SupplierOrdersBloc>().add(
                                      const SupplierOrdersRefreshed(),
                                    );
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.orders.length,
                                itemBuilder: (context, index) {
                                  final order = state.orders[index];

                                  return SupplierOrderCard(
                                    order: order,
                                    onViewDetails: () {
                                      _goToDetails(context, order);
                                    },
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(SupplierOrderStatus status) {
    switch (status) {
      case SupplierOrderStatus.pending:
        return 'Pending';
      case SupplierOrderStatus.accepted:
        return 'Accepted';
      case SupplierOrderStatus.preparing:
        return 'Preparing';
      case SupplierOrderStatus.shipped:
        return 'Shipped';
      case SupplierOrderStatus.delivered:
        return 'Delivered';
      case SupplierOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? primary : AppThemeTokens.border,
            ),
          ),
          child: Text(
            count == null ? label : '$label ($count)',
            style: TextStyle(
              color: isSelected ? primary : AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 58,
              color: primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'No orders found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Incoming retailer orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../bloc/supplier_orders/supplier_orders_bloc.dart';
import '../bloc/supplier_orders/supplier_orders_event.dart';
import '../bloc/supplier_orders/supplier_orders_state.dart';
import '../widgets/supplier_order_card.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

class SupplierOrdersScreen extends StatelessWidget {
  SupplierOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierOrdersBloc>(
      create: (_) => sl<SupplierOrdersBloc>()..add(SupplierOrdersStarted()),
      child: _SupplierOrdersView(),
    );
  }
}

class _SupplierOrdersView extends StatefulWidget {
  _SupplierOrdersView();

  @override
  State<_SupplierOrdersView> createState() => _SupplierOrdersViewState();
}

class _SupplierOrdersViewState extends State<_SupplierOrdersView> {
  final TextEditingController _searchController = TextEditingController();

  final List<SupplierOrderStatus> _statuses = [
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
      '/supplier-orders/details/${order.id}',
      extra: order,
    );

    if (!context.mounted) return;

    if (result == true) {
      context.read<SupplierOrdersBloc>().add(SupplierOrdersRefreshed());
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
        AppToast.error(context, state.errorMessage!);
      },
      child: Scaffold(
        backgroundColor: AppThemeTokens.background,
        drawer: SupplierAppDrawer(),
        appBar: AppBar(
          backgroundColor: AppThemeTokens.background,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu),
              );
            },
          ),
          title: Text(
            context.l10n.supplierOrdersTitle,
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
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<SupplierOrdersBloc>().add(
                            SupplierOrdersSearchChanged(value),
                          );
                    },
                    decoration: InputDecoration(
                      hintText: context.l10n.searchOrdersHint,
                      prefixIcon: Icon(
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _StatusFilterChip(
                        label: context.l10n.allLabel,
                        count: null,
                        isSelected: state.selectedStatus == null,
                        onTap: () {
                          context.read<SupplierOrdersBloc>().add(
                                SupplierOrdersStatusFilterChanged(null),
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
                SizedBox(height: 10),
                Divider(height: 1, color: AppThemeTokens.border),
                Expanded(
                  child: state.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : state.orders.isEmpty
                          ? _EmptyOrdersView()
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<SupplierOrdersBloc>().add(
                                      SupplierOrdersRefreshed(),
                                    );
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
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
      case SupplierOrderStatus.pendingPayment:
        return _supplierAwaitingPaymentLabel(context);
      case SupplierOrderStatus.pending:
        return context.l10n.orderStatusPending;
      case SupplierOrderStatus.accepted:
        return context.l10n.orderStatusAccepted;
      case SupplierOrderStatus.preparing:
        return context.l10n.orderStatusPreparing;
      case SupplierOrderStatus.shipped:
        return context.l10n.orderStatusShipped;
      case SupplierOrderStatus.delivered:
        return context.l10n.orderStatusDelivered;
      case SupplierOrderStatus.cancelled:
        return context.l10n.orderStatusCancelled;
    }
  }

  String _supplierAwaitingPaymentLabel(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'ar') return 'بانتظار الدفع';
    if (languageCode == 'fr') return 'En attente de paiement';
    return 'Awaiting payment';
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  _StatusFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
  _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 58,
              color: primary,
            ),
            SizedBox(height: 14),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.incomingOrdersEmptyMessage,
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

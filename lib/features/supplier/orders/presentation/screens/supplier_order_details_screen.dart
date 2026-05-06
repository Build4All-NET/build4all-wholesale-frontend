import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../bloc/supplier_order_details/supplier_order_details_bloc.dart';
import '../bloc/supplier_order_details/supplier_order_details_event.dart';
import '../bloc/supplier_order_details/supplier_order_details_state.dart';
import '../widgets/order_status_badge.dart';

class SupplierOrderDetailsScreen extends StatelessWidget {
  final SupplierOrderEntity order;

  const SupplierOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierOrderDetailsBloc>(
      create: (_) => sl<SupplierOrderDetailsBloc>()
        ..add(
          SupplierOrderDetailsStarted(
            orderId: order.id,
            initialOrder: order,
          ),
        ),
      child: const _SupplierOrderDetailsView(),
    );
  }
}

class _SupplierOrderDetailsView extends StatelessWidget {
  const _SupplierOrderDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupplierOrderDetailsBloc, SupplierOrderDetailsState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
        }
      },
      builder: (context, state) {
        final order = state.order;

        if (state.isLoading && order == null) {
          return const Scaffold(
            backgroundColor: AppThemeTokens.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (order == null) {
          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              backgroundColor: AppThemeTokens.background,
              elevation: 0,
              title: const Text(
                'Order Details',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            body: const Center(
              child: Text(
                'Order not found',
                style: TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }

        return _OrderDetailsContent(
          order: order,
          isUpdating: state.isUpdating,
        );
      },
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  final SupplierOrderEntity order;
  final bool isUpdating;

  const _OrderDetailsContent({
    required this.order,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
                fontSize: 20,
              ),
            ),
            Text(
              order.orderNumber,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrderSummary(primary),
                    const SizedBox(height: 16),
                    _buildStatusTimeline(primary),
                    const SizedBox(height: 16),
                    _buildProductsCard(),
                    const SizedBox(height: 16),
                    _buildDeliveryCard(),
                    if (order.notes != null &&
                        order.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildNotesCard(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildActionArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.retailerName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.deliveryAddress,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeTokens.inputFill,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Order Date',
                  value: _formatFullDate(order.orderDate),
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  label: 'Payment Method',
                  value: order.paymentMethod,
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  label: 'Total Amount',
                  value: _formatMoney(order.totalAmount),
                  valueColor: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Color primary) {
    final statuses = [
      SupplierOrderStatus.pending,
      SupplierOrderStatus.accepted,
      SupplierOrderStatus.preparing,
      SupplierOrderStatus.shipped,
      SupplierOrderStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(order.status);

    if (order.status == SupplierOrderStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppThemeTokens.error),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'This order was cancelled.',
                style: TextStyle(
                  color: AppThemeTokens.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(statuses.length, (index) {
              final status = statuses[index];
              final isCompleted = index <= currentIndex;
              final isLast = index == statuses.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted ? primary : AppThemeTokens.border,
                        size: 22,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 28,
                          color:
                              isCompleted ? primary : AppThemeTokens.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontWeight:
                            isCompleted ? FontWeight.w900 : FontWeight.w700,
                        color: isCompleted
                            ? AppThemeTokens.textPrimary
                            : AppThemeTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products Ordered',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          ...order.items.map((item) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item.quantity} units × ${_formatMoney(item.unitPrice)}',
                            style: const TextStyle(
                              color: AppThemeTokens.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatMoney(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (item != order.items.last) ...[
                  const SizedBox(height: 14),
                  const Divider(color: AppThemeTokens.border),
                  const SizedBox(height: 14),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Retailer Phone',
            value: order.retailerPhone,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Delivery Address',
            value: order.deliveryAddress,
          ),
          if (order.branchName != null &&
              order.branchName!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              label: 'Branch',
              value: order.branchName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            order.notes!,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    final actions = _getAvailableActions(context);

    if (actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: const BoxDecoration(
          color: AppThemeTokens.background,
          border: Border(
            top: BorderSide(color: AppThemeTokens.border),
          ),
        ),
        child: const Text(
          'No more status actions available for this order.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: AppThemeTokens.background,
        border: Border(
          top: BorderSide(color: AppThemeTokens.border),
        ),
      ),
      child: Column(
        children: actions,
      ),
    );
  }

  List<Widget> _getAvailableActions(BuildContext context) {
    switch (order.status) {
      case SupplierOrderStatus.pending:
        return [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Reject Order',
                  icon: Icons.cancel_outlined,
                  color: AppThemeTokens.error,
                  isOutlined: true,
                  isLoading: isUpdating,
                  onPressed: () => _updateStatus(
                    context,
                    SupplierOrderStatus.cancelled,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Accept Order',
                  icon: Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  isLoading: isUpdating,
                  onPressed: () => _updateStatus(
                    context,
                    SupplierOrderStatus.accepted,
                  ),
                ),
              ),
            ],
          ),
        ];

      case SupplierOrderStatus.accepted:
        return [
          _ActionButton(
            label: 'Mark Preparing',
            icon: Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.primary,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.preparing,
            ),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Cancel Order',
            icon: Icons.cancel_outlined,
            color: AppThemeTokens.error,
            isOutlined: true,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.cancelled,
            ),
          ),
        ];

      case SupplierOrderStatus.preparing:
        return [
          _ActionButton(
            label: 'Ship Order',
            icon: Icons.local_shipping_outlined,
            color: Theme.of(context).colorScheme.primary,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.shipped,
            ),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Cancel Order',
            icon: Icons.cancel_outlined,
            color: AppThemeTokens.error,
            isOutlined: true,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.cancelled,
            ),
          ),
        ];

      case SupplierOrderStatus.shipped:
        return [
          _ActionButton(
            label: 'Mark Delivered',
            icon: Icons.task_alt,
            color: Theme.of(context).colorScheme.primary,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.delivered,
            ),
          ),
        ];

      case SupplierOrderStatus.delivered:
      case SupplierOrderStatus.cancelled:
        return [];
    }
  }

  void _updateStatus(BuildContext context, SupplierOrderStatus status) {
    context.read<SupplierOrderDetailsBloc>().add(
          SupplierOrderDetailsStatusUpdateRequested(status),
        );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppThemeTokens.surface,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
      border: Border.all(color: AppThemeTokens.border),
    );
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatFullDate(DateTime date) {
    final month = _monthName(date.month);
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month ${date.day}, ${date.year}, $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isOutlined;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          ),
        ),
        child: child,
      ),
    );
  }
}
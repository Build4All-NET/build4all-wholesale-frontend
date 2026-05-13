import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../bloc/supplier_order_details/supplier_order_details_bloc.dart';
import '../bloc/supplier_order_details/supplier_order_details_event.dart';
import '../bloc/supplier_order_details/supplier_order_details_state.dart';
import '../widgets/order_status_badge.dart';

class SupplierOrderDetailsScreen extends StatelessWidget {
  final SupplierOrderEntity order;

  SupplierOrderDetailsScreen({
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
      child: _SupplierOrderDetailsView(),
    );
  }
}

class _SupplierOrderDetailsView extends StatelessWidget {
  _SupplierOrderDetailsView();

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
          return Scaffold(
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
              title: Text(
                context.l10n.orderDetailsTitle,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            body: Center(
              child: Text(
                context.l10n.orderNotFound,
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

  _OrderDetailsContent({
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
          icon: Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.orderDetailsTitle,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
                fontSize: 20,
              ),
            ),
            Text(
              order.orderNumber,
              style: TextStyle(
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
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOrderSummary(context, primary),
                    SizedBox(height: 16),
                    _buildStatusTimeline(context, primary),
                    SizedBox(height: 16),
                    _buildProductsCard(context),
                    SizedBox(height: 16),
                    _buildDeliveryCard(context),
                    if (order.notes != null &&
                        order.notes!.trim().isNotEmpty) ...[
                      SizedBox(height: 16),
                      _buildNotesCard(context),
                    ],
                    SizedBox(height: 100),
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

  Widget _buildOrderSummary(BuildContext context, Color primary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.retailerName,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          SizedBox(height: 6),
          Text(
            order.deliveryAddress,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeTokens.inputFill,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: context.l10n.orderDateLabel,
                  value: _formatFullDate(order.orderDate),
                ),
                SizedBox(height: 14),
                _InfoRow(
                  label: context.l10n.paymentMethodLabel,
                  value: order.paymentMethod,
                ),
                SizedBox(height: 14),
                _InfoRow(
                  label: context.l10n.totalAmountLabel,
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

  Widget _buildStatusTimeline(BuildContext context, Color primary) {
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
        padding: EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppThemeTokens.error),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.orderCancelledMessage,
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
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderTimelineLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 16),
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
                  SizedBox(width: 12),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      _statusLabel(context, status),
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

  Widget _buildProductsCard(context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productsOrderedTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 18),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            context.l10n.unitsTimesPrice(item.quantity, _formatMoney(item.unitPrice)),
                            style: TextStyle(
                              color: AppThemeTokens.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatMoney(item.totalPrice),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (item != order.items.last) ...[
                  SizedBox(height: 14),
                  Divider(color: AppThemeTokens.border),
                  SizedBox(height: 14),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.deliveryInformationTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 14),
          _InfoRow(
            label: context.l10n.retailerPhoneLabel,
            value: order.retailerPhone,
          ),
          SizedBox(height: 14),
          _InfoRow(
            label: context.l10n.deliveryAddressLabel,
            value: order.deliveryAddress,
          ),
          if (order.branchName != null &&
              order.branchName!.trim().isNotEmpty) ...[
            SizedBox(height: 14),
            _InfoRow(
              label: context.l10n.branchLabelPlain,
              value: order.branchName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderNotesTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            order.notes!,
            style: TextStyle(
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
        padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: BoxDecoration(
          color: AppThemeTokens.background,
          border: Border(
            top: BorderSide(color: AppThemeTokens.border),
          ),
        ),
        child: Text(
          context.l10n.noMoreStatusActions,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
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
                  label: context.l10n.rejectOrderButton,
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
              SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: context.l10n.acceptOrderButton,
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
            label: context.l10n.markPreparingButton,
            icon: Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.primary,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.preparing,
            ),
          ),
          SizedBox(height: 10),
          _ActionButton(
            label: context.l10n.cancelOrderButton,
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
            label: context.l10n.shipOrderButton,
            icon: Icons.local_shipping_outlined,
            color: Theme.of(context).colorScheme.primary,
            isLoading: isUpdating,
            onPressed: () => _updateStatus(
              context,
              SupplierOrderStatus.shipped,
            ),
          ),
          SizedBox(height: 10),
          _ActionButton(
            label: context.l10n.cancelOrderButton,
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
            label: context.l10n.markDeliveredButton,
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

  String _statusLabel(BuildContext context, SupplierOrderStatus status) {
    switch (status) {
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  _InfoRow({
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
            style: TextStyle(
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

  _ActionButton({
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
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
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

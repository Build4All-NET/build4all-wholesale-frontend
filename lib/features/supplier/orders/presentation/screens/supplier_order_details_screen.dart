import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/repositories/supplier_order_repository_impl.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../../domain/repositories/supplier_order_repository.dart';
import '../../domain/usecases/update_supplier_order_status_usecase.dart';
import '../widgets/order_status_badge.dart';
class SupplierOrderDetailsScreen extends StatefulWidget {
  final SupplierOrderEntity order;

  const SupplierOrderDetailsScreen({super.key, required this.order});

  @override
  State<SupplierOrderDetailsScreen> createState() =>
      _SupplierOrderDetailsScreenState();
}

class _SupplierOrderDetailsScreenState
    extends State<SupplierOrderDetailsScreen> {
  final SupplierOrderRepository _orderRepository =
    SupplierOrderRepositoryImpl();

late final UpdateSupplierOrderStatusUseCase _updateSupplierOrderStatusUseCase =
    UpdateSupplierOrderStatusUseCase(_orderRepository);
  late SupplierOrderEntity _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(SupplierOrderStatus status) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedOrder = await _updateSupplierOrderStatusUseCase(
  orderId: _order.id,
  status: status,
);

      if (!mounted) return;

      setState(() {
        _order = updatedOrder;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ${status.label}')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
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
                _order.orderNumber,
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
                      if (_order.notes != null &&
                          _order.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildNotesCard(),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildActionArea(),
            ],
          ),
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
                  _order.retailerName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              OrderStatusBadge(status: _order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _order.deliveryAddress,
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
                  value: _formatFullDate(_order.orderDate),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Payment Method', value: _order.paymentMethod),
                const SizedBox(height: 14),
                _InfoRow(
                  label: 'Total Amount',
                  value: _formatMoney(_order.totalAmount),
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

    final currentIndex = statuses.indexOf(_order.status);

    if (_order.status == SupplierOrderStatus.cancelled) {
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
                          color: isCompleted ? primary : AppThemeTokens.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: isCompleted
                            ? FontWeight.w900
                            : FontWeight.w700,
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
          ..._order.items.map((item) {
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
                if (item != _order.items.last) ...[
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
          _InfoRow(label: 'Retailer Phone', value: _order.retailerPhone),
          const SizedBox(height: 14),
          _InfoRow(label: 'Delivery Address', value: _order.deliveryAddress),
          if (_order.branchName != null &&
              _order.branchName!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(label: 'Branch', value: _order.branchName!),
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
            _order.notes!,
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

  Widget _buildActionArea() {
    final actions = _getAvailableActions();

    if (actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: const BoxDecoration(
          color: AppThemeTokens.background,
          border: Border(top: BorderSide(color: AppThemeTokens.border)),
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
        border: Border(top: BorderSide(color: AppThemeTokens.border)),
      ),
      child: Column(children: actions),
    );
  }

  List<Widget> _getAvailableActions() {
    switch (_order.status) {
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
                  isLoading: _isUpdating,
                  onPressed: () => _updateStatus(SupplierOrderStatus.cancelled),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Accept Order',
                  icon: Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  isLoading: _isUpdating,
                  onPressed: () => _updateStatus(SupplierOrderStatus.accepted),
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
            isLoading: _isUpdating,
            onPressed: () => _updateStatus(SupplierOrderStatus.preparing),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Cancel Order',
            icon: Icons.cancel_outlined,
            color: AppThemeTokens.error,
            isOutlined: true,
            isLoading: _isUpdating,
            onPressed: () => _updateStatus(SupplierOrderStatus.cancelled),
          ),
        ];

      case SupplierOrderStatus.preparing:
        return [
          _ActionButton(
            label: 'Ship Order',
            icon: Icons.local_shipping_outlined,
            color: Theme.of(context).colorScheme.primary,
            isLoading: _isUpdating,
            onPressed: () => _updateStatus(SupplierOrderStatus.shipped),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Cancel Order',
            icon: Icons.cancel_outlined,
            color: AppThemeTokens.error,
            isOutlined: true,
            isLoading: _isUpdating,
            onPressed: () => _updateStatus(SupplierOrderStatus.cancelled),
          ),
        ];

      case SupplierOrderStatus.shipped:
        return [
          _ActionButton(
            label: 'Mark Delivered',
            icon: Icons.task_alt,
            color: Theme.of(context).colorScheme.primary,
            isLoading: _isUpdating,
            onPressed: () => _updateStatus(SupplierOrderStatus.delivered),
          ),
        ];

      case SupplierOrderStatus.delivered:
      case SupplierOrderStatus.cancelled:
        return [];
    }
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

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
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
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

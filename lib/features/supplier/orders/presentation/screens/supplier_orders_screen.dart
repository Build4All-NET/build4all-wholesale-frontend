import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/repositories/supplier_order_repository_impl.dart';
import '../../domain/entities/supplier_order_entity.dart';
import '../../domain/repositories/supplier_order_repository.dart';
import '../../domain/usecases/get_supplier_orders_usecase.dart';
import '../widgets/supplier_order_card.dart';

class SupplierOrdersScreen extends StatefulWidget {
  const SupplierOrdersScreen({super.key});

  @override
  State<SupplierOrdersScreen> createState() => _SupplierOrdersScreenState();
}

class _SupplierOrdersScreenState extends State<SupplierOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final SupplierOrderRepository _orderRepository =
      SupplierOrderRepositoryImpl();

  late final GetSupplierOrdersUseCase _getSupplierOrdersUseCase =
      GetSupplierOrdersUseCase(_orderRepository);
  Timer? _searchDebounce;

  bool _isLoading = true;
  String _searchText = '';
  SupplierOrderStatus? _selectedStatus;

  List<SupplierOrderEntity> _orders = [];

  final List<SupplierOrderStatus> _statuses = const [
    SupplierOrderStatus.pending,
    SupplierOrderStatus.accepted,
    SupplierOrderStatus.preparing,
    SupplierOrderStatus.shipped,
    SupplierOrderStatus.delivered,
    SupplierOrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _getSupplierOrdersUseCase(
        query: _searchText,
        status: _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(e);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
    });

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), _loadOrders);
  }

  Future<void> _selectStatus(SupplierOrderStatus? status) async {
    setState(() {
      _selectedStatus = status;
    });

    await _loadOrders();
  }

  Future<void> _goToDetails(SupplierOrderEntity order) async {
    final result = await context.push<bool>(
      '/supplier-orders/details',
      extra: order,
    );

    if (result == true) {
      await _loadOrders();
    }
  }

  int _countByStatus(SupplierOrderStatus status) {
  return _orderRepository.countByStatus(status);
}

  void _showError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
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
                  isSelected: _selectedStatus == null,
                  onTap: () => _selectStatus(null),
                ),
                ..._statuses.map(
                  (status) => _StatusFilterChip(
                    label: status.label,
                    count: _countByStatus(status),
                    isSelected: _selectedStatus == status,
                    onTap: () => _selectStatus(status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppThemeTokens.border),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                ? const _EmptyOrdersView()
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        return SupplierOrderCard(
                          order: order,
                          onViewDetails: () => _goToDetails(order),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
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
            Icon(Icons.receipt_long_outlined, size: 58, color: primary),
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

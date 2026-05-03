import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/widgets/primary_button.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_cart_model.dart';
import '../cubit/retailer_cart_cubit.dart';
import '../cubit/retailer_cart_state.dart';

class RetailerCartScreen extends StatelessWidget {
  const RetailerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerCartCubit>()..loadCart(),
      child: const _RetailerCartView(),
    );
  }
}

class _RetailerCartView extends StatelessWidget {
  const _RetailerCartView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<RetailerCartCubit, RetailerCartState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RetailerCartCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cart = state.cart;

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l10n.shoppingCart,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Center(
                  child: Text(
                    cart == null
                        ? ''
                        : '${cart.totalItems} ${cart.totalItems == 1 ? l10n.item : l10n.items}',
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading && cart == null
              ? const Center(child: CircularProgressIndicator())
              : cart == null || cart.items.isEmpty
              ? const _EmptyCartView()
              : _CartContent(cart: cart, updatingItemId: state.updatingItemId),
        );
      },
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, color: primaryColor, size: 72),
            const SizedBox(height: 18),
            Text(
              l10n.yourCartIsEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyCartMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final RetailerCartModel cart;
  final int? updatingItemId;

  const _CartContent({required this.cart, required this.updatingItemId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
        children: [
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CartItemCard(
                item: item,
                isUpdating: updatingItemId == item.id,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _OrderSummaryCard(cart: cart),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.continueShopping,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: l10n.proceedToCheckout,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.checkoutComingSoon)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final RetailerCartItemModel item;
  final bool isUpdating;

  const _CartItemCard({required this.item, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RetailerCartCubit>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _ProductImage(imageUrl: item.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.currency}${item.unitPrice.toStringAsFixed(2)} ${l10n.perUnit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityControl(item: item, isUpdating: isUpdating),
                    const Spacer(),
                    Text(
                      '${item.currency}${item.lineTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isUpdating
                ? null
                : () => cubit.deleteItem(cartItemId: item.id),
            icon: isUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: AppThemeTokens.error,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl!.trim().isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: AppThemeTokens.textSecondary,
              size: 36,
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  color: AppThemeTokens.textSecondary,
                  size: 36,
                );
              },
            ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final RetailerCartItemModel item;
  final bool isUpdating;

  const _QuantityControl({required this.item, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RetailerCartCubit>();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isUpdating || item.quantity <= item.moq
                ? null
                : () => cubit.decreaseQuantity(
                    cartItemId: item.id,
                    currentQuantity: item.quantity,
                    moq: item.moq,
                  ),
            icon: const Icon(Icons.remove, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          SizedBox(
            width: 42,
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: isUpdating
                ? null
                : () => cubit.increaseQuantity(
                    cartItemId: item.id,
                    currentQuantity: item.quantity,
                    moq: item.moq,
                  ),
            icon: const Icon(Icons.add, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final RetailerCartModel cart;

  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currency = cart.items.isEmpty ? r'$' : cart.items.first.currency;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummary,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: l10n.subtotal,
            value: '$currency${cart.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: l10n.shippingEstimated,
            value: '$currency${cart.shippingEstimated.toStringAsFixed(2)}',
          ),
          const Divider(height: 28),
          _SummaryRow(
            label: l10n.total,
            value: '$currency${cart.total.toStringAsFixed(2)}',
            isTotal: true,
            totalColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? totalColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.totalColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isTotal
                  ? AppThemeTokens.textPrimary
                  : AppThemeTokens.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? (totalColor ?? AppThemeTokens.textPrimary)
                : AppThemeTokens.textPrimary,
            fontSize: isTotal ? 17 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

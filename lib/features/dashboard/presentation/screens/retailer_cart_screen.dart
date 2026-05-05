import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                fontSize: 22,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading && cart == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
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
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.screenHorizontalPadding,
          12,
          AppThemeTokens.screenHorizontalPadding,
          24,
        ),
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

          // Full-width buttons so text is not cut on real phone screens.
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppThemeTokens.border),
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.continueShopping,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.checkoutComingSoon)));
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.proceedToCheckout,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
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
        color: AppThemeTokens.surface,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(imageUrl: item.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textPrimary,
                          fontSize: 16,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.currency}${item.unitPrice.toStringAsFixed(2)} ${l10n.perUnit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.moq}: ${item.moq} ${item.moqUnit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  onPressed: isUpdating
                      ? null
                      : () => cubit.deleteItem(cartItemId: item.id),
                  padding: EdgeInsets.zero,
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.delete_outline_rounded,
                          color: AppThemeTokens.error,
                          size: 25,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Separate bottom row avoids overflow.
          Row(
            children: [
              _QuantityControl(item: item, isUpdating: isUpdating),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.currency}${item.lineTotal.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
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
    final cleanImageUrl = imageUrl?.trim();

    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl == null || cleanImageUrl.isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: AppThemeTokens.textSecondary,
              size: 36,
            )
          : Image.network(
              cleanImageUrl,
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
      height: 38,
      constraints: const BoxConstraints(maxWidth: 150),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              onPressed: isUpdating || item.quantity <= item.moq
                  ? null
                  : () => cubit.decreaseQuantity(
                      cartItemId: item.id,
                      currentQuantity: item.quantity,
                      moq: item.moq,
                    ),
              icon: const Icon(Icons.remove_rounded, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              onPressed: isUpdating
                  ? null
                  : () => cubit.increaseQuantity(
                      cartItemId: item.id,
                      currentQuantity: item.quantity,
                      moq: item.moq,
                    ),
              icon: const Icon(Icons.add_rounded, size: 18),
              padding: EdgeInsets.zero,
            ),
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
        color: AppThemeTokens.surface,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: l10n.subtotal,
            value: '$currency${cart.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.shippingEstimated,
            value: '$currency${cart.shippingEstimated.toStringAsFixed(2)}',
          ),
          const Divider(height: 30),
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
              fontSize: isTotal ? 17 : 15,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isTotal
                ? (totalColor ?? AppThemeTokens.textPrimary)
                : AppThemeTokens.textPrimary,
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

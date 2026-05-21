import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../dashboard/presentation/widgets/retailer_product_image.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';

class RetailerOrderItemsSection extends StatelessWidget {
  final RetailerOrderEntity order;

  const RetailerOrderItemsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.orderItems,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  RetailerProductImage(
                    imageUrl: item.imageUrl,
                    width: 58,
                    height: 58,
                    borderRadius: 14,
                    iconSize: 28,
                  ),
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
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} × ${formatRetailerOrderCurrency(context, item.unitPrice)}',
                          style: const TextStyle(
                            color: AppThemeTokens.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRetailerOrderCurrency(context, item.totalPrice),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

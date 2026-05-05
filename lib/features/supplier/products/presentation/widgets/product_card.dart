import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final totalStock = product.totalStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImagePlaceholder(
            primaryColor: primaryColor,
            imagePath: product.imagePath,
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.subCategoryName == null ||
                    product.subCategoryName!.trim().isEmpty
                ? product.categoryName
                : '${product.categoryName} • ${product.subCategoryName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              _StatusBadge(status: product.status),
            ],
          ),
          const SizedBox(height: 10),
          _InventoryStockBadge(totalStock: totalStock),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: const BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.error,
                  side: const BorderSide(color: AppThemeTokens.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 14,
                  ),
                ),
                child: const Icon(Icons.delete_outline, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final Color primaryColor;
  final String? imagePath;

  const _ProductImagePlaceholder({
    required this.primaryColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      height: 245,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: hasImage && File(imagePath!).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(
                AppThemeTokens.radiusMedium,
              ),
              child: Image.file(
                File(imagePath!),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: primaryColor.withOpacity(0.75),
            ),
    );
  }
}

class _InventoryStockBadge extends StatelessWidget {
  final int totalStock;

  const _InventoryStockBadge({
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = totalStock == 0;
    final color = isOutOfStock
        ? AppThemeTokens.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Text(
        isOutOfStock
            ? 'No branch stock assigned'
            : 'Total Branch Stock: $totalStock',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == ProductStatus.active;
    final label = isActive ? 'Active' : 'Inactive';
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : AppThemeTokens.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
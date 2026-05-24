import 'dart:io';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import 'package:flutter/material.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ProductCard({
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
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: Offset(0, 6),
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
          SizedBox(height: 16),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            product.subCategoryName == null ||
                    product.subCategoryName!.trim().isEmpty
                ? product.categoryName
                : '${product.categoryName} • ${product.subCategoryName}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          SizedBox(height: 14),
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
              Spacer(),
              _StatusBadge(status: product.status),
            ],
          ),
          SizedBox(height: 10),
          _InventoryStockBadge(totalStock: totalStock),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 20),
                  label: Text(
                    context.l10n.editButton,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.error,
                  side: BorderSide(color: AppThemeTokens.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 14,
                  ),
                ),
                child: Icon(Icons.delete_outline, size: 22),
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

  _ProductImagePlaceholder({
    required this.primaryColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _resolveImageUrl(imagePath);
    final localFile = _resolveLocalFile(imagePath);

    return Container(
      height: 245,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: localFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(
                AppThemeTokens.radiusMedium,
              ),
              child: Image.file(
                localFile,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          : resolvedImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusMedium,
                  ),
                  child: Image.network(
                    resolvedImageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _ImageFallbackIcon(primaryColor: primaryColor);
                    },
                  ),
                )
              : _ImageFallbackIcon(primaryColor: primaryColor),
    );
  }

  File? _resolveLocalFile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = value.trim();

    if (normalized.startsWith('/uploadsPublic/') ||
        normalized.startsWith('http://') ||
        normalized.startsWith('https://')) {
      return null;
    }

    final file = File(normalized);

    return file.existsSync() ? file : null;
  }

  String? _resolveImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = value.trim();

    if (normalized.startsWith('http://') ||
        normalized.startsWith('https://')) {
      return normalized;
    }

    if (normalized.startsWith('/uploadsPublic/')) {
      return '${_projectHostWithoutApi()}$normalized';
    }

    return null;
  }

  String _projectHostWithoutApi() {
    final baseUrl = AppConfig.projectApiBaseUrl;

    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }

    return baseUrl;
  }
}

class _ImageFallbackIcon extends StatelessWidget {
  final Color primaryColor;

  _ImageFallbackIcon({
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.inventory_2_outlined,
      size: 72,
      color: primaryColor.withOpacity(0.75),
    );
  }
}


class _InventoryStockBadge extends StatelessWidget {
  final int totalStock;

  _InventoryStockBadge({
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = totalStock == 0;
    final color = isOutOfStock
        ? AppThemeTokens.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Text(
        isOutOfStock
            ? context.l10n.noBranchStockAssigned
            : context.l10n.totalBranchStockLabel(totalStock),
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

  _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == ProductStatus.active;
    final label = isActive ? context.l10n.activeStatus : context.l10n.inactiveStatus;
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : AppThemeTokens.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

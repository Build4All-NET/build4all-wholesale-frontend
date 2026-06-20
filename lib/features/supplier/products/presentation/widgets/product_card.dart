import 'dart:io';

import 'package:build4all_wholesale_frontend/core/currency/currency_formatter.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(
              primaryColor: primaryColor,
              imagePath: product.imagePath,
              status: product.status,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _categoryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(context, product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    _InventoryStockBadge(totalStock: product.totalStock),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 31,
                            child: OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: Icon(Icons.edit_outlined, size: 14),
                              label: Text(
                                context.l10n.editButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppThemeTokens.textPrimary,
                                side: BorderSide(color: AppThemeTokens.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 6),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        SizedBox(
                          width: 34,
                          height: 31,
                          child: OutlinedButton(
                            onPressed: onDelete,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppThemeTokens.error,
                              side: BorderSide(color: AppThemeTokens.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(Icons.delete_outline, size: 17),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _categoryText {
    final subCategory = product.subCategoryName?.trim();
    if (subCategory == null || subCategory.isEmpty) {
      return product.categoryName;
    }
    return '${product.categoryName} • $subCategory';
  }
}

class _ProductImage extends StatelessWidget {
  final Color primaryColor;
  final String? imagePath;
  final ProductStatus status;

  _ProductImage({
    required this.primaryColor,
    required this.imagePath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _resolveImageUrl(imagePath);
    final localFile = _resolveLocalFile(imagePath);

    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: AppThemeTokens.inputFill),
            child: localFile != null
                ? Image.file(
                    localFile,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  )
                : resolvedImageUrl != null
                    ? Image.network(
                        resolvedImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return _ImageFallbackIcon(primaryColor: primaryColor);
                        },
                      )
                    : _ImageFallbackIcon(primaryColor: primaryColor),
          ),
          PositionedDirectional(
            top: 7,
            end: 7,
            child: _StatusBadge(status: status),
          ),
        ],
      ),
    );
  }

  File? _resolveLocalFile(String? value) {
    if (value == null || value.trim().isEmpty) return null;

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
    if (value == null || value.trim().isEmpty) return null;

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

  _ImageFallbackIcon({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 38,
        color: primaryColor.withOpacity(0.68),
      ),
    );
  }
}

class _InventoryStockBadge extends StatelessWidget {
  final int totalStock;

  _InventoryStockBadge({required this.totalStock});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = totalStock == 0;
    final color = isOutOfStock
        ? AppThemeTokens.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Text(
        isOutOfStock
            ? context.l10n.noBranchStockAssigned
            : context.l10n.totalBranchStockLabel(totalStock),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9.3,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductStatus status;

  _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == ProductStatus.active;
    final label = isActive ? context.l10n.activeStatus : context.l10n.inactiveStatus;
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : AppThemeTokens.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

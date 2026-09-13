import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../utils/supplier_excel_import_i18n.dart';

/// The products the import would create, with the ones missing something marked
/// and fixable before anything is written.
class SupplierForeignReviewList extends StatelessWidget {
  final SupplierForeignPreview preview;

  /// Called when the supplier types a price onto a row that had none.
  final void Function(int row, double price) onPriceChanged;

  const SupplierForeignReviewList({
    super.key,
    required this.preview,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.foreignPreviewTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            ),
            Text(
              l.foreignPreviewCount(preview.products.length),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
        if (preview.skippedRows > 0) ...[
          const SizedBox(height: 4),
          Text(
            l.foreignSkippedRows(preview.skippedRows),
            style: const TextStyle(
              fontSize: 12,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
        if (preview.needingAttention > 0) ...[
          const SizedBox(height: 4),
          Text(
            l.foreignNeedingAttention(preview.needingAttention),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...preview.products.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProductRow(
              product: product,
              onPriceChanged: (price) => onPriceChanged(product.row, price),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatefulWidget {
  final SupplierForeignProductPreview product;
  final ValueChanged<double> onPriceChanged;

  const _ProductRow({required this.product, required this.onPriceChanged});

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  late final TextEditingController _price = TextEditingController(
    text: widget.product.price?.toString() ?? '',
  );

  @override
  void didUpdateWidget(_ProductRow old) {
    super.didUpdateWidget(old);

    // The preview is re-read from the server after every correction, so the
    // value arrives back from outside the field. Without this the row would
    // stop showing a price the supplier had just typed into it.
    final incoming = widget.product.price?.toString() ?? '';
    if (incoming != old.product.price?.toString() && incoming != _price.text) {
      _price.text = incoming;
    }
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final product = widget.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: product.valid
              ? AppThemeTokens.border
              : AppThemeTokens.error.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              Text(
                '#${product.row}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
          if (product.categoryName != null) ...[
            const SizedBox(height: 2),
            Text(
              product.categoryName!,
              style: const TextStyle(
                fontSize: 12,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l.foreignField('PRICE'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: AppThemeTokens.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppThemeTokens.border),
                    ),
                  ),
                  onSubmitted: (value) {
                    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
                    if (parsed != null) widget.onPriceChanged(parsed);
                  },
                ),
              ),
              if (product.stock != null) ...[
                const SizedBox(width: 10),
                _Chip(
                  label: l.foreignField('STOCK'),
                  value: '${product.stock}',
                ),
              ],
              if (product.moq != null) ...[
                const SizedBox(width: 10),
                _Chip(label: l.foreignField('MOQ'), value: '${product.moq}'),
              ],
            ],
          ),
          if (product.issues.isNotEmpty || product.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...product.issues.map(
                  (code) => _Flag(text: _word(l, code), isIssue: true),
                ),
                ...product.notes.map(
                  (code) => _Flag(text: _word(l, code), isIssue: false),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// The server sends codes so this reads in the supplier's own language.
  static String _word(SupplierExcelImportI18n l, String code) {
    switch (code) {
      case 'NO_PRICE':
        return l.foreignIssueNoPrice;
      case 'NO_QUANTITY':
        return l.foreignNoteNoQuantity;
      case 'STOCK_NEEDS_BRANCH':
        return l.foreignNoteStockNeedsBranch;
      default:
        return code;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;

  const _Chip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppThemeTokens.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppThemeTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  final String text;
  final bool isIssue;

  const _Flag({required this.text, required this.isIssue});

  @override
  Widget build(BuildContext context) {
    final color =
        isIssue ? AppThemeTokens.error : AppThemeTokens.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

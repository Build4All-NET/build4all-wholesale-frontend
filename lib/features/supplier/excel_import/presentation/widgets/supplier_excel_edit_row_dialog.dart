import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelEditRowDialog extends StatefulWidget {
  final SupplierExcelProductRowEntity row;
  final List<SupplierCategoryEntity> categories;
  final Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId;

  const SupplierExcelEditRowDialog({
    super.key,
    required this.row,
    required this.categories,
    required this.subCategoriesByCategoryId,
  });

  @override
  State<SupplierExcelEditRowDialog> createState() =>
      _SupplierExcelEditRowDialogState();
}

class _SupplierExcelEditRowDialogState
    extends State<SupplierExcelEditRowDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _moqController;

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String _selectedStatus = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.row.productName);
    _descriptionController = TextEditingController(text: widget.row.description);
    _priceController = TextEditingController(text: widget.row.priceText);
    _moqController = TextEditingController(text: widget.row.moqText);

    _selectedCategoryId = widget.row.categoryId ?? _matchCategoryIdByName();
    _selectedSubCategoryId = widget.row.subCategoryId ?? _matchSubCategoryIdByName();
    _selectedStatus = _normalizeStatus(widget.row.statusText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _moqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final selectedSubCategories = _selectedCategoryId == null
        ? <SupplierSubCategoryEntity>[]
        : widget.subCategoriesByCategoryId[_selectedCategoryId] ?? [];

    if (_selectedSubCategoryId != null &&
        !selectedSubCategories.any((sub) => sub.id == _selectedSubCategoryId)) {
      _selectedSubCategoryId = null;
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.edit_outlined, color: primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Row ${widget.row.rowNumber}',
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Correct the product information before importing. This updates the preview only; it does not change the Excel file on your phone.',
                style: TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              _TextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 12),
              _TextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_outlined,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _DropdownField<String>(
                label: 'Category',
                icon: Icons.category_outlined,
                value: _selectedCategoryId,
                hint: widget.row.categoryName.isEmpty
                    ? 'Select category'
                    : 'Select category (${widget.row.categoryName})',
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedSubCategoryId = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              _DropdownField<String?>(
                label: 'SubCategory (optional)',
                icon: Icons.account_tree_outlined,
                value: _selectedSubCategoryId,
                hint: selectedSubCategories.isEmpty
                    ? 'No subcategories for this category'
                    : 'Select subcategory',
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No subcategory'),
                  ),
                  ...selectedSubCategories.map(
                    (subCategory) => DropdownMenuItem<String?>(
                      value: subCategory.id,
                      child: Text(subCategory.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedSubCategoryId = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextField(
                      controller: _moqController,
                      label: 'MOQ',
                      icon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DropdownField<String>(
                label: 'Status',
                icon: Icons.toggle_on_outlined,
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                ],
                onChanged: (value) {
                  setState(() => _selectedStatus = value ?? 'ACTIVE');
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final category = _selectedCategoryId == null
        ? null
        : widget.categories.firstWhere(
            (item) => item.id == _selectedCategoryId,
          );

    final subCategories = _selectedCategoryId == null
        ? <SupplierSubCategoryEntity>[]
        : widget.subCategoriesByCategoryId[_selectedCategoryId] ?? [];

    final subCategory = _selectedSubCategoryId == null
        ? null
        : subCategories.firstWhere(
            (item) => item.id == _selectedSubCategoryId,
          );

    final updatedRow = widget.row.copyWith(
      productName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryName: category?.name ?? widget.row.categoryName.trim(),
      subCategoryName: subCategory?.name ?? '',
      priceText: _priceController.text.trim(),
      moqText: _moqController.text.trim(),
      statusText: _selectedStatus,
      categoryId: category?.id,
      subCategoryId: subCategory?.id,
      clearCategoryId: category == null,
      clearSubCategoryId: subCategory == null,
      clearParsedPrice: true,
      clearParsedMoq: true,
      clearParsedStatus: true,
      errors: const [],
      warnings: const [],
    );

    Navigator.of(context).pop(updatedRow);
  }

  String? _matchCategoryIdByName() {
    final normalizedName = _normalize(widget.row.categoryName);
    if (normalizedName.isEmpty) return null;

    for (final category in widget.categories) {
      if (_normalize(category.name) == normalizedName) return category.id;
    }

    return null;
  }

  String? _matchSubCategoryIdByName() {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return null;

    final normalizedName = _normalize(widget.row.subCategoryName);
    if (normalizedName.isEmpty) return null;

    final subCategories = widget.subCategoriesByCategoryId[categoryId] ?? [];
    for (final subCategory in subCategories) {
      if (_normalize(subCategory.name) == normalizedName) {
        return subCategory.id;
      }
    }

    return null;
  }

  String _normalizeStatus(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized == 'INACTIVE') return 'INACTIVE';
    return 'ACTIVE';
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

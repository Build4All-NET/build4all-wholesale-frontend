import 'dart:io';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/repositories/supplier_category_repository.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class AddProductScreen extends StatefulWidget {
  final ProductEntity? productToEdit;

  AddProductScreen({super.key, this.productToEdit});

  bool get isEditMode => productToEdit != null;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final SupplierCategoryRepository _categoryRepository =
      sl<SupplierCategoryRepository>();

  final ProductRepository _productRepository = sl<ProductRepository>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minimumOrderQuantityController = TextEditingController(text: '10');

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String? _selectedImagePath;
  ProductStatus _selectedStatus = ProductStatus.active;

  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = false;
  bool _isSavingProduct = false;
  bool _isCreatingCategory = false;
  bool _isCreatingSubCategory = false;
  bool _isDeletingCategory = false;
  bool _isDeletingSubCategory = false;

  List<SupplierCategoryEntity> _categories = [];
  List<SupplierSubCategoryEntity> _subCategories = [];

  @override
  void initState() {
    super.initState();

    final product = widget.productToEdit;

    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _minimumOrderQuantityController.text = product.minimumOrderQuantity
          .toString();

      _selectedCategoryId = product.categoryId;
      _selectedSubCategoryId = product.subCategoryId;
      _selectedImagePath = product.imagePath;
      _selectedStatus = product.status;
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minimumOrderQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await _categoryRepository.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });

      if (_selectedCategoryId != null) {
        final exists = _categories.any(
          (category) => category.id == _selectedCategoryId,
        );

        if (exists) {
          await _loadSubCategoriesByCategory(_selectedCategoryId!);
        } else {
          setState(() {
            _selectedCategoryId = null;
            _selectedSubCategoryId = null;
            _subCategories = [];
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
      });

      _showError(e);
    }
  }

  Future<void> _loadSubCategoriesByCategory(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
    });

    try {
      final subCategories = await _categoryRepository
          .getSubCategoriesByCategory(categoryId: categoryId);

      if (!mounted) return;

      setState(() {
        _subCategories = subCategories;
        _isLoadingSubCategories = false;

        final selectedStillExists = _subCategories.any(
          (subCategory) => subCategory.id == _selectedSubCategoryId,
        );

        if (!selectedStillExists) {
          _selectedSubCategoryId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSubCategories = false;
        _subCategories = [];
        _selectedSubCategoryId = null;
      });

      _showError(e);
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImagePath = pickedImage.path;
    });
  }

  Future<void> _showAddCategoryDialog() async {
    if (_isCreatingCategory) return;

    final controller = TextEditingController();

    final categoryName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.addCategoryTitle, style: TextStyle(fontWeight: FontWeight.w900)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: context.l10n.categoryNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 3) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(context.l10n.addButton),
            ),
          ],
        );
      },
    );

    if (categoryName == null || categoryName.trim().isEmpty) return;

    setState(() {
      _isCreatingCategory = true;
    });

    try {
      final category = await _categoryRepository.createCategory(
        name: categoryName,
      );

      if (!mounted) return;

      setState(() {
        _categories = [..._categories, category];
        _selectedCategoryId = category.id;
        _selectedSubCategoryId = null;
        _subCategories = [];
        _isCreatingCategory = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.categoryAddedMessage(category.name))));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCreatingCategory = false;
      });

      _showError(e);
    }
  }

  Future<void> _showAddSubCategoryDialog() async {
    if (_isCreatingSubCategory) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.selectCategoryFirstMessage)));
      return;
    }

    final controller = TextEditingController();

    final subCategoryName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.addSubCategoryTitle, style: TextStyle(fontWeight: FontWeight.w900)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: context.l10n.subCategoryNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 3) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(context.l10n.addButton),
            ),
          ],
        );
      },
    );

    if (subCategoryName == null || subCategoryName.trim().isEmpty) return;

    setState(() {
      _isCreatingSubCategory = true;
    });

    try {
      final subCategory = await _categoryRepository.createSubCategory(
        categoryId: _selectedCategoryId!,
        name: subCategoryName,
      );

      if (!mounted) return;

      setState(() {
        _subCategories = [..._subCategories, subCategory];
        _selectedSubCategoryId = subCategory.id;
        _isCreatingSubCategory = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.subCategoryAddedMessage(subCategory.name))));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCreatingSubCategory = false;
      });

      _showError(e);
    }
  }

  Future<void> _deleteSelectedCategory() async {
    if (_isDeletingCategory) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.selectCategoryFirstMessage)));
      return;
    }

    final selectedCategory = _categories
        .where((category) => category.id == _selectedCategoryId)
        .cast<SupplierCategoryEntity?>()
        .firstWhere((category) => category != null, orElse: () => null);

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectedCategoryNotFound)),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.deleteCategoryTitle, style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text(
            '${context.l10n.deleteCategoryPermanentConfirmation(selectedCategory.name)}\n\n${context.l10n.deleteCategoryHelp}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeletingCategory = true;
    });

    try {
      await _categoryRepository.deleteCategory(categoryId: selectedCategory.id);

      if (!mounted) return;

      setState(() {
        _categories = _categories
            .where((category) => category.id != selectedCategory.id)
            .toList();

        _selectedCategoryId = null;
        _selectedSubCategoryId = null;
        _subCategories = [];
        _isDeletingCategory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.categoryDeletedMessage(selectedCategory.name))),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeletingCategory = false;
      });

      _showError(e);
    }
  }

  Future<void> _deleteSelectedSubCategory() async {
    if (_isDeletingSubCategory) return;

    if (_selectedSubCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectSubCategoryFirstMessage)),
      );
      return;
    }

    final selectedSubCategory = _subCategories
        .where((subCategory) => subCategory.id == _selectedSubCategoryId)
        .cast<SupplierSubCategoryEntity?>()
        .firstWhere((subCategory) => subCategory != null, orElse: () => null);

    if (selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectedSubCategoryNotFound)),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.deleteSubCategoryTitle, style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text(
            '${context.l10n.deleteSubCategoryPermanentConfirmation(selectedSubCategory.name)}\n\n${context.l10n.deleteSubCategoryHelp}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeletingSubCategory = true;
    });

    try {
      await _categoryRepository.deleteSubCategory(
        subCategoryId: selectedSubCategory.id,
      );

      if (!mounted) return;

      setState(() {
        _subCategories = _subCategories
            .where((subCategory) => subCategory.id != selectedSubCategory.id)
            .toList();

        _selectedSubCategoryId = null;
        _isDeletingSubCategory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.subCategoryDeletedMessage(selectedSubCategory.name))),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeletingSubCategory = false;
      });

      _showError(e);
    }
  }

  Future<void> _saveProduct() async {
    if (_isSavingProduct) return;
    if (!_formKey.currentState!.validate()) return;

    final selectedCategory = _categories
        .where((category) => category.id == _selectedCategoryId)
        .cast<SupplierCategoryEntity?>()
        .firstWhere((category) => category != null, orElse: () => null);

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectedCategoryNotFound)),
      );
      return;
    }

    final selectedSubCategory = _selectedSubCategoryId == null
        ? null
        : _subCategories
              .where((subCategory) => subCategory.id == _selectedSubCategoryId)
              .cast<SupplierSubCategoryEntity?>()
              .firstWhere(
                (subCategory) => subCategory != null,
                orElse: () => null,
              );

    setState(() {
      _isSavingProduct = true;
    });

    try {
      final ProductEntity product;

      if (widget.isEditMode) {
        product = await _productRepository.updateProduct(
          productId: widget.productToEdit!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: selectedCategory.id,
          subCategoryId: selectedSubCategory?.id,
          price: double.parse(_priceController.text.trim()),
          minimumOrderQuantity: int.parse(
            _minimumOrderQuantityController.text.trim(),
          ),
          status: _selectedStatus,
          imagePath: _selectedImagePath,
        );
      } else {
        product = await _productRepository.createProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: selectedCategory.id,
          subCategoryId: selectedSubCategory?.id,
          price: double.parse(_priceController.text.trim()),
          minimumOrderQuantity: int.parse(
            _minimumOrderQuantityController.text.trim(),
          ),
          status: _selectedStatus,
          imagePath: _selectedImagePath,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSavingProduct = false;
      });

      context.pop(product);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSavingProduct = false;
      });

      _showError(e);
    }
  }

  void _showError(Object error) {
    final message = error is AppException
        ? error.message
        : error.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = widget.isEditMode ? context.l10n.editProductTitle : context.l10n.addProductTitle;
    final buttonText = widget.isEditMode ? context.l10n.updateProductButton : context.l10n.saveProductButton;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: AppThemeTokens.background,
            border: Border(top: BorderSide(color: AppThemeTokens.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSavingProduct ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: BorderSide(color: AppThemeTokens.border),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingProduct ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSavingProduct
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoadingCategories
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 24),
                children: [
                  _SectionCard(
                    title: context.l10n.productInformationTitle,
                    children: [
                      _AppTextField(
                        label: context.l10n.productNameLabel,
                        hint: context.l10n.productNameHint,
                        controller: _nameController,
                        validator: (value) {
                          final name = value?.trim() ?? '';

                          if (name.isEmpty) return context.l10n.productNameRequiredError;
                          if (name.length < 3) {
                            return context.l10n.productNameMinError;
                          }
                          if (name.length > 80) {
                            return context.l10n.productNameTooLongError;
                          }

                          return null;
                        },
                      ),
                      _AppTextField(
                        label: context.l10n.productDescriptionLabel,
                        hint: context.l10n.productDescriptionHint,
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) {
                          final description = value?.trim() ?? '';

                          if (description.isEmpty) {
                            return context.l10n.productDescriptionRequiredError;
                          }
                          if (description.length < 10) {
                            return context.l10n.productDescriptionMinError;
                          }
                          if (description.length > 300) {
                            return context.l10n.productDescriptionTooLongError;
                          }

                          return null;
                        },
                      ),
                      _CategorySelector(
                        selectedCategoryId: _selectedCategoryId,
                        categories: _categories,
                        isCreatingCategory: _isCreatingCategory,
                        isDeletingCategory: _isDeletingCategory,
                        onChanged: (value) async {
                          setState(() {
                            _selectedCategoryId = value;
                            _selectedSubCategoryId = null;
                            _subCategories = [];
                          });

                          if (value != null) {
                            await _loadSubCategoriesByCategory(value);
                          }
                        },
                        onAddCategory: _showAddCategoryDialog,
                        onDeleteCategory: _deleteSelectedCategory,
                      ),

                      _SubCategorySelector(
                        selectedSubCategoryId: _selectedSubCategoryId,
                        subCategories: _subCategories,
                        isEnabled:
                            _selectedCategoryId != null &&
                            !_isLoadingSubCategories,
                        isLoading: _isLoadingSubCategories,
                        isCreatingSubCategory: _isCreatingSubCategory,
                        isDeletingSubCategory: _isDeletingSubCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCategoryId = value;
                          });
                        },
                        onAddSubCategory: _showAddSubCategoryDialog,
                        onDeleteSubCategory: _deleteSelectedSubCategory,
                      ),

                      _AppTextField(
                        label: context.l10n.pricePerUnitLabel,
                        hint: '0.00',
                        controller: _priceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final price = double.tryParse(value?.trim() ?? '');

                          if (price == null) return context.l10n.productPriceInvalidError;
                          if (price <= 0) {
                            return context.l10n.priceGreaterThanZeroError;
                          }
                          if (price > 100000) return context.l10n.priceTooHighError;

                          return null;
                        },
                      ),
                      _AppTextField(
                        label: context.l10n.minimumOrderQuantityLabel,
                        hint: '10',
                        controller: _minimumOrderQuantityController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final quantity = int.tryParse(value?.trim() ?? '');

                          if (quantity == null) {
                            return context.l10n.quantityInvalidError;
                          }
                          if (quantity < 5) {
                            return context.l10n.moqWholesaleMinError;
                          }
                          if (quantity > 10000) {
                            return context.l10n.moqTooHighError;
                          }

                          return null;
                        },
                      ),
                      _StatusSelector(
                        selectedStatus: _selectedStatus,
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      _UploadImagesBox(
                        imagePath: _selectedImagePath,
                        onTap: _pickImage,
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _InventoryManagedInfoCard(
                    isEditMode: widget.isEditMode,
                    product: widget.productToEdit,
                  ),
                ],
              ),
            ),
    );
  }
}

class _InventoryManagedInfoCard extends StatelessWidget {
  final bool isEditMode;
  final ProductEntity? product;

  _InventoryManagedInfoCard({
    required this.isEditMode,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.inventory_2_outlined, color: primaryColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.productBranchStockTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      isEditMode
                          ? context.l10n.manageProductStockSavedNote
                          : context.l10n.manageProductStockAfterSaveNote,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          if (isEditMode && product != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/supplier-products/branch-stock',
                    extra: product,
                  );
                },
                icon: Icon(Icons.store_mall_directory_outlined),
                label: Text(
                  context.l10n.productBranchStockTitle,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withOpacity(0.35)),
                  padding: EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeTokens.inputFill,
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppThemeTokens.textSecondary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l10n.branchStockAfterSaveNote,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final List<SupplierCategoryEntity> categories;
  final bool isCreatingCategory;
  final bool isDeletingCategory;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddCategory;
  final VoidCallback onDeleteCategory;

  _CategorySelector({
    required this.selectedCategoryId,
    required this.categories,
    required this.isCreatingCategory,
    required this.isDeletingCategory,
    required this.onChanged,
    required this.onAddCategory,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedCategoryId = categories.any(
      (category) => category.id == selectedCategoryId,
    )
        ? selectedCategoryId
        : null;

    return _DropdownSection(
      label: context.l10n.categoryLabel,
      dropdown: DropdownButtonFormField<String>(
        initialValue: safeSelectedCategoryId,
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.l10n.categoryRequiredError;
          }
          return null;
        },
        decoration: _dropdownDecoration(context.l10n.selectCategoryHint),
      ),
      addButtonText: isCreatingCategory ? context.l10n.addingLabel : context.l10n.addCategoryTitle,
      onAddPressed: isCreatingCategory ? null : onAddCategory,
      deleteButtonText:
          isDeletingCategory ? context.l10n.deletingLabel : context.l10n.deleteSelectedCategory,
      onDeletePressed: safeSelectedCategoryId == null || isDeletingCategory
          ? null
          : onDeleteCategory,
    );
  }
}

class _SubCategorySelector extends StatelessWidget {
  final String? selectedSubCategoryId;
  final List<SupplierSubCategoryEntity> subCategories;
  final bool isEnabled;
  final bool isLoading;
  final bool isCreatingSubCategory;
  final bool isDeletingSubCategory;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddSubCategory;
  final VoidCallback onDeleteSubCategory;

  _SubCategorySelector({
    required this.selectedSubCategoryId,
    required this.subCategories,
    required this.isEnabled,
    required this.isLoading,
    required this.isCreatingSubCategory,
    required this.isDeletingSubCategory,
    required this.onChanged,
    required this.onAddSubCategory,
    required this.onDeleteSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedSubCategoryId = subCategories.any(
      (subCategory) => subCategory.id == selectedSubCategoryId,
    )
        ? selectedSubCategoryId
        : null;

    return _DropdownSection(
      label: context.l10n.subCategoryLabel,
      dropdown: DropdownButtonFormField<String>(
        initialValue: safeSelectedSubCategoryId,
        items: subCategories.map((subCategory) {
          return DropdownMenuItem<String>(
            value: subCategory.id,
            child: Text(subCategory.name),
          );
        }).toList(),
        onChanged: isEnabled ? onChanged : null,
        decoration: _dropdownDecoration(
          isLoading
              ? context.l10n.loadingSubCategories
              : isEnabled
                  ? context.l10n.selectSubCategoryIfNeeded
                  : context.l10n.selectCountryFirst,
        ),
      ),
      addButtonText:
          isCreatingSubCategory ? 'Adding...' : context.l10n.addSubCategoryTitle,
      onAddPressed:
          isEnabled && !isCreatingSubCategory ? onAddSubCategory : null,
      deleteButtonText: isDeletingSubCategory
          ? context.l10n.deletingLabel
          : context.l10n.deleteSelectedSubCategory,
      onDeletePressed:
          safeSelectedSubCategoryId == null || isDeletingSubCategory
              ? null
              : onDeleteSubCategory,
    );
  }
}


class _StatusSelector extends StatelessWidget {
  final ProductStatus selectedStatus;
  final ValueChanged<ProductStatus?> onChanged;

  _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productStatusLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<ProductStatus>(
            initialValue: selectedStatus,
            items: [
              DropdownMenuItem(
                value: ProductStatus.active,
                child: Text(context.l10n.activeStatus),
              ),
              DropdownMenuItem(
                value: ProductStatus.inactive,
                child: Text(context.l10n.inactiveStatus),
              ),
            ],
            onChanged: onChanged,
            decoration: _dropdownDecoration(context.l10n.selectProductStatus),
          ),
        ],
      ),
    );
  }
}

class _DropdownSection extends StatelessWidget {
  final String label;
  final Widget dropdown;
  final String addButtonText;
  final VoidCallback? onAddPressed;
  final String deleteButtonText;
  final VoidCallback? onDeletePressed;

  _DropdownSection({
    required this.label,
    required this.dropdown,
    required this.addButtonText,
    required this.onAddPressed,
    required this.deleteButtonText,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          dropdown,
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TextButton.icon(
                onPressed: onAddPressed,
                icon: Icon(Icons.add, size: 18),
                label: Text(
                  addButtonText,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: onAddPressed == null
                      ? AppThemeTokens.textSecondary
                      : primaryColor,
                ),
              ),
              TextButton.icon(
                onPressed: onDeletePressed,
                icon: Icon(Icons.delete_outline, size: 18),
                label: Text(
                  deleteButtonText,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: onDeletePressed == null
                      ? AppThemeTokens.textSecondary
                      : AppThemeTokens.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


InputDecoration _dropdownDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppThemeTokens.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: BorderSide(color: AppThemeTokens.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: BorderSide(color: AppThemeTokens.error),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  _AppTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppThemeTokens.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                borderSide: BorderSide(color: AppThemeTokens.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                borderSide: BorderSide(color: AppThemeTokens.error),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadImagesBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  _UploadImagesBox({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localFile = _resolveLocalFile(imagePath);
    final networkImageUrl = _resolveNetworkImageUrl(imagePath);
    final hasImage = localFile != null || networkImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.uploadImagesTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          child: Container(
            width: double.infinity,
            height: hasImage ? 190 : null,
            padding: hasImage
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(vertical: 28, horizontal: 18),
            decoration: BoxDecoration(
              color: AppThemeTokens.surface,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                    child: localFile != null
                        ? Image.file(
                            localFile,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            networkImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _UploadImagePlaceholder();
                            },
                          ),
                  )
                : _UploadImagePlaceholder(),
          ),
        ),
      ],
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

  String? _resolveNetworkImageUrl(String? value) {
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

class _UploadImagePlaceholder extends StatelessWidget {
  _UploadImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload_outlined,
          size: 38,
          color: AppThemeTokens.textSecondary,
        ),
        SizedBox(height: 10),
        Text(
          context.l10n.tapToUploadProductImage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          context.l10n.imageFormatHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}



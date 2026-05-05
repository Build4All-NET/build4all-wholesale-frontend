import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  const AddProductScreen({
    super.key,
    this.productToEdit,
  });

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
      _minimumOrderQuantityController.text =
          product.minimumOrderQuantity.toString();

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
          title: const Text(
            'Add Category',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Furniture, Stationery',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 3) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Add'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.name} added')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a category first'),
        ),
      );
      return;
    }

    final controller = TextEditingController();

    final subCategoryName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Sub Category',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Office Chairs, Notebooks',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 3) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Add'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${subCategory.name} added')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCreatingSubCategory = false;
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
        const SnackBar(
          content: Text('Selected category was not found'),
        ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = widget.isEditMode ? 'Edit Product' : 'Add Product';
    final buttonText = widget.isEditMode ? 'Update Product' : 'Save Product';

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: const BoxDecoration(
            color: AppThemeTokens.background,
            border: Border(
              top: BorderSide(color: AppThemeTokens.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSavingProduct ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: const BorderSide(color: AppThemeTokens.border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingProduct ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSavingProduct
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                children: [
                  _SectionCard(
                    title: 'Product Information',
                    children: [
                      _AppTextField(
                        label: 'Product Name *',
                        hint: 'e.g., Coca-Cola 24-Pack, Cotton T-Shirt Box',
                        controller: _nameController,
                        validator: (value) {
                          final name = value?.trim() ?? '';

                          if (name.isEmpty) return 'Product name is required';
                          if (name.length < 3) {
                            return 'Product name must be at least 3 characters';
                          }
                          if (name.length > 80) {
                            return 'Product name is too long';
                          }

                          return null;
                        },
                      ),
                      _AppTextField(
                        label: 'Description *',
                        hint: 'Write a clear wholesale product description...',
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) {
                          final description = value?.trim() ?? '';

                          if (description.isEmpty) {
                            return 'Description is required';
                          }
                          if (description.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          if (description.length > 300) {
                            return 'Description is too long';
                          }

                          return null;
                        },
                      ),
                      _CategorySelector(
                        selectedCategoryId: _selectedCategoryId,
                        categories: _categories,
                        isCreatingCategory: _isCreatingCategory,
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
                      ),
                      _SubCategorySelector(
                        selectedSubCategoryId: _selectedSubCategoryId,
                        subCategories: _subCategories,
                        isEnabled: _selectedCategoryId != null &&
                            !_isLoadingSubCategories,
                        isLoading: _isLoadingSubCategories,
                        isCreatingSubCategory: _isCreatingSubCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCategoryId = value;
                          });
                        },
                        onAddSubCategory: _showAddSubCategoryDialog,
                      ),
                      _AppTextField(
                        label: 'Price per Unit *',
                        hint: '0.00',
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final price = double.tryParse(value?.trim() ?? '');

                          if (price == null) return 'Enter a valid price';
                          if (price <= 0) {
                            return 'Price must be greater than 0';
                          }
                          if (price > 100000) return 'Price is too high';

                          return null;
                        },
                      ),
                      _AppTextField(
                        label: 'Minimum Order Quantity *',
                        hint: '10',
                        controller: _minimumOrderQuantityController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final quantity = int.tryParse(value?.trim() ?? '');

                          if (quantity == null) {
                            return 'Enter a valid quantity';
                          }
                          if (quantity < 5) {
                            return 'Minimum order quantity must be at least 5 for wholesale';
                          }
                          if (quantity > 10000) {
                            return 'Minimum order quantity is too high';
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
                  const SizedBox(height: 18),
                  _InventoryManagedInfoCard(
                    isEditMode: widget.isEditMode,
                  ),
                ],
              ),
            ),
    );
  }
}

class _InventoryManagedInfoCard extends StatelessWidget {
  final bool isEditMode;

  const _InventoryManagedInfoCard({
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(
                Icons.inventory_2_outlined,
                color: primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Branch Inventory',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEditMode
                          ? 'Product details are saved here. Stock is assigned per branch from Branch Inventory.'
                          : 'Save this product first, then assign its stock per branch from Branch Inventory.',
                      style: const TextStyle(
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
          const SizedBox(height: 14),
          if (isEditMode)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/supplier-branches');
                },
                icon: const Icon(Icons.store_mall_directory_outlined),
                label: const Text(
                  'Manage Branch Inventory',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withOpacity(0.35)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppThemeTokens.inputFill,
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppThemeTokens.textSecondary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Branch stock becomes available after saving the product.',
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
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddCategory;

  const _CategorySelector({
    required this.selectedCategoryId,
    required this.categories,
    required this.isCreatingCategory,
    required this.onChanged,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedCategoryId = categories.any(
      (category) => category.id == selectedCategoryId,
    )
        ? selectedCategoryId
        : null;

    return _DropdownSection(
      label: 'Category *',
      dropdown: DropdownButtonFormField<String>(
        value: safeSelectedCategoryId,
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Category is required';
          }
          return null;
        },
        decoration: _dropdownDecoration('Select category'),
      ),
      buttonText: isCreatingCategory ? 'Adding...' : 'Add Category',
      onButtonPressed: isCreatingCategory ? null : onAddCategory,
    );
  }
}

class _SubCategorySelector extends StatelessWidget {
  final String? selectedSubCategoryId;
  final List<SupplierSubCategoryEntity> subCategories;
  final bool isEnabled;
  final bool isLoading;
  final bool isCreatingSubCategory;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddSubCategory;

  const _SubCategorySelector({
    required this.selectedSubCategoryId,
    required this.subCategories,
    required this.isEnabled,
    required this.isLoading,
    required this.isCreatingSubCategory,
    required this.onChanged,
    required this.onAddSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedSubCategoryId = subCategories.any(
      (subCategory) => subCategory.id == selectedSubCategoryId,
    )
        ? selectedSubCategoryId
        : null;

    return _DropdownSection(
      label: 'Sub Category',
      dropdown: DropdownButtonFormField<String>(
        value: safeSelectedSubCategoryId,
        items: subCategories.map((subCategory) {
          return DropdownMenuItem<String>(
            value: subCategory.id,
            child: Text(subCategory.name),
          );
        }).toList(),
        onChanged: isEnabled ? onChanged : null,
        decoration: _dropdownDecoration(
          isLoading
              ? 'Loading sub categories...'
              : isEnabled
                  ? 'Select sub category if needed'
                  : 'Select category first',
        ),
      ),
      buttonText: isCreatingSubCategory ? 'Adding...' : 'Add Sub Category',
      onButtonPressed:
          isEnabled && !isCreatingSubCategory ? onAddSubCategory : null,
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final ProductStatus selectedStatus;
  final ValueChanged<ProductStatus?> onChanged;

  const _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Status *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ProductStatus>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(
                value: ProductStatus.active,
                child: Text('Active'),
              ),
              DropdownMenuItem(
                value: ProductStatus.inactive,
                child: Text('Inactive'),
              ),
            ],
            onChanged: onChanged,
            decoration: _dropdownDecoration('Select product status'),
          ),
        ],
      ),
    );
  }
}

class _DropdownSection extends StatelessWidget {
  final String label;
  final Widget dropdown;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const _DropdownSection({
    required this.label,
    required this.dropdown,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          dropdown,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: TextButton.styleFrom(
                foregroundColor: onButtonPressed == null
                    ? AppThemeTokens.textSecondary
                    : primaryColor,
              ),
            ),
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
      borderSide: const BorderSide(color: AppThemeTokens.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      borderSide: const BorderSide(color: AppThemeTokens.error),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
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

  const _AppTextField({
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
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
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
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: const BorderSide(color: AppThemeTokens.error),
              ),
              contentPadding: const EdgeInsets.symmetric(
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

  const _UploadImagesBox({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Images',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          child: Container(
            width: double.infinity,
            height: hasImage ? 190 : null,
            padding: hasImage
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
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
                    child: Image.file(
                      File(imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    children: [
                      Icon(
                        Icons.upload_outlined,
                        size: 38,
                        color: AppThemeTokens.textSecondary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap to upload product image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PNG, JPG up to 10MB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
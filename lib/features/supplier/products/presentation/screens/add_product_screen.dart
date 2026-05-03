import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../branches/data/branch_mock_store.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../categories/data/supplier_category_mock_store.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../data/product_mock_store.dart';
import '../../domain/entities/product_entity.dart';

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

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minimumOrderQuantityController = TextEditingController(text: '10');

  final Map<String, TextEditingController> _branchStockControllers = {};

  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  String? _selectedImagePath;
  ProductStatus _selectedStatus = ProductStatus.active;

  List<SupplierCategoryEntity> get _categories {
    return SupplierCategoryMockStore.categories;
  }

  List<SupplierSubCategoryEntity> get _subCategories {
    if (_selectedCategoryId == null) return [];

    return SupplierCategoryMockStore.getSubCategoriesByCategoryId(
      _selectedCategoryId!,
    );
  }

  List<BranchEntity> get _branches {
    return BranchMockStore.branches;
  }

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

    _syncBranchStockControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minimumOrderQuantityController.dispose();

    for (final controller in _branchStockControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _syncBranchStockControllers() {
    final currentBranchIds = _branches.map((branch) => branch.id).toSet();

    for (final branch in _branches) {
      if (_branchStockControllers.containsKey(branch.id)) continue;

      final initialStock = widget.productToEdit == null
          ? 0
          : BranchMockStore.getProductStockForBranch(
              branchId: branch.id,
              productId: widget.productToEdit!.id,
            );

      _branchStockControllers[branch.id] = TextEditingController(
        text: initialStock.toString(),
      );
    }

    final removedBranchIds = _branchStockControllers.keys
        .where((branchId) => !currentBranchIds.contains(branchId))
        .toList();

    for (final branchId in removedBranchIds) {
      _branchStockControllers[branchId]?.dispose();
      _branchStockControllers.remove(branchId);
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

    final category = SupplierCategoryMockStore.addCategory(categoryName);

    if (!mounted) return;

    setState(() {
      _selectedCategoryId = category.id;
      _selectedSubCategoryId = null;
    });
  }

  Future<void> _showAddSubCategoryDialog() async {
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

    final subCategory = SupplierCategoryMockStore.addSubCategory(
      categoryId: _selectedCategoryId!,
      name: subCategoryName,
    );

    if (!mounted) return;

    setState(() {
      _selectedSubCategoryId = subCategory.id;
    });
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategory = SupplierCategoryMockStore.getCategoryById(
      _selectedCategoryId!,
    );

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected category was not found'),
        ),
      );
      return;
    }

    final selectedSubCategory = SupplierCategoryMockStore.getSubCategoryById(
      _selectedSubCategoryId,
    );

    final productId = widget.productToEdit?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final product = ProductEntity(
      id: productId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: selectedCategory.id,
      categoryName: selectedCategory.name,
      subCategoryId: selectedSubCategory?.id,
      subCategoryName: selectedSubCategory?.name,
      price: double.parse(_priceController.text.trim()),
      minimumOrderQuantity: int.parse(
        _minimumOrderQuantityController.text.trim(),
      ),
      status: _selectedStatus,
      imagePath: _selectedImagePath,
    );

    if (widget.isEditMode) {
      ProductMockStore.updateProduct(product);
    } else {
      ProductMockStore.addProduct(product);
    }

    final categoryDisplayName = selectedSubCategory == null
        ? selectedCategory.name
        : '${selectedCategory.name} • ${selectedSubCategory.name}';

    final stockByBranchId = <String, int>{};

    for (final branch in _branches) {
      final controller = _branchStockControllers[branch.id];
      final stock = int.tryParse(controller?.text.trim() ?? '0') ?? 0;
      stockByBranchId[branch.id] = stock;
    }

    BranchMockStore.setProductInventoryAllocations(
      productId: product.id,
      productName: product.name,
      categoryName: categoryDisplayName,
      stockByBranchId: stockByBranchId,
    );

    context.pop(product);
  }

  @override
  Widget build(BuildContext context) {
    _syncBranchStockControllers();

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
                  onPressed: () => context.pop(),
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
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
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
                    if (name.length > 80) return 'Product name is too long';

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

                    if (description.isEmpty) return 'Description is required';
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
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedSubCategoryId = null;
                    });
                  },
                  onAddCategory: _showAddCategoryDialog,
                ),
                _SubCategorySelector(
                  selectedSubCategoryId: _selectedSubCategoryId,
                  subCategories: _subCategories,
                  isEnabled: _selectedCategoryId != null,
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
                    if (price <= 0) return 'Price must be greater than 0';
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

                    if (quantity == null) return 'Enter a valid quantity';
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
            _BranchStockAllocationSection(
              branches: _branches,
              stockControllers: _branchStockControllers,
              validator: _stockValidator,
            ),
          ],
        ),
      ),
    );
  }

  String? _stockValidator(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');

    if (stock == null) return 'Enter valid stock';
    if (stock < 0) return 'Stock cannot be negative';
    if (stock > 1000000) return 'Stock quantity is too high';

    return null;
  }
}

class _BranchStockAllocationSection extends StatelessWidget {
  final List<BranchEntity> branches;
  final Map<String, TextEditingController> stockControllers;
  final String? Function(String?) validator;

  const _BranchStockAllocationSection({
    required this.branches,
    required this.stockControllers,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return _SectionCard(
        title: 'Branch Stock Allocation',
        children: const [
          Text(
            'No branches available. Add supplier branches first to allocate product stock.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'Branch Stock Allocation',
      children: [
        const Text(
          'Set initial stock per branch. Product info stays separate, and stock is saved in Branch Inventory.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        ...branches.map((branch) {
          final controller = stockControllers[branch.id];

          if (controller == null) {
            return const SizedBox.shrink();
          }

          return _AppTextField(
            label: '${branch.name} Stock',
            hint: '0',
            controller: controller,
            keyboardType: TextInputType.number,
            validator: validator,
          );
        }),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final List<SupplierCategoryEntity> categories;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddCategory;

  const _CategorySelector({
    required this.selectedCategoryId,
    required this.categories,
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
      buttonText: 'Add Category',
      onButtonPressed: onAddCategory,
    );
  }
}

class _SubCategorySelector extends StatelessWidget {
  final String? selectedSubCategoryId;
  final List<SupplierSubCategoryEntity> subCategories;
  final bool isEnabled;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddSubCategory;

  const _SubCategorySelector({
    required this.selectedSubCategoryId,
    required this.subCategories,
    required this.isEnabled,
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
          isEnabled ? 'Select sub category if needed' : 'Select category first',
        ),
      ),
      buttonText: 'Add Sub Category',
      onButtonPressed: isEnabled ? onAddSubCategory : null,
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
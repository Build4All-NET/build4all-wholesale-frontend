import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
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
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _minimumOrderQuantityController = TextEditingController(text: '10');
  final _beirutStockController = TextEditingController(text: '0');
  final _tripoliStockController = TextEditingController(text: '0');
  final _saidaStockController = TextEditingController(text: '0');

  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();

    final product = widget.productToEdit;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _categoryController.text = product.category;
      _priceController.text = product.price.toStringAsFixed(2);
      _minimumOrderQuantityController.text =
          product.minimumOrderQuantity.toString();
      _beirutStockController.text = product.beirutStock.toString();
      _tripoliStockController.text = product.tripoliStock.toString();
      _saidaStockController.text = product.saidaStock.toString();
      _selectedImagePath = product.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _minimumOrderQuantityController.dispose();
    _beirutStockController.dispose();
    _tripoliStockController.dispose();
    _saidaStockController.dispose();
    super.dispose();
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

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final beirutStock = int.parse(_beirutStockController.text.trim());
    final tripoliStock = int.parse(_tripoliStockController.text.trim());
    final saidaStock = int.parse(_saidaStockController.text.trim());

    final totalStock = beirutStock + tripoliStock + saidaStock;

    if (totalStock == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one branch must have stock'),
        ),
      );
      return;
    }

    final product = ProductEntity(
      id: widget.productToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      minimumOrderQuantity: int.parse(
        _minimumOrderQuantityController.text.trim(),
      ),
      stockQuantity: totalStock,
      beirutStock: beirutStock,
      tripoliStock: tripoliStock,
      saidaStock: saidaStock,
      status: totalStock <= 20 ? ProductStatus.lowStock : ProductStatus.active,
      imagePath: _selectedImagePath,
    );

    if (widget.isEditMode) {
      ProductMockStore.updateProduct(product);
    } else {
      ProductMockStore.addProduct(product);
    }

    context.pop(product);
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
                _AppTextField(
                  label: 'Category *',
                  hint: 'e.g., Clothing, Beverages, Electronics',
                  controller: _categoryController,
                  validator: (value) {
                    final category = value?.trim() ?? '';

                    if (category.isEmpty) return 'Category is required';
                    if (category.length < 3) {
                      return 'Category must be at least 3 characters';
                    }
                    if (category.length > 60) {
                      return 'Category is too long';
                    }

                    return null;
                  },
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
                _UploadImagesBox(
                  imagePath: _selectedImagePath,
                  onTap: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionCard(
              title: 'Branch Stock Allocation',
              children: [
                _AppTextField(
                  label: 'Beirut Branch Stock',
                  hint: '0',
                  controller: _beirutStockController,
                  keyboardType: TextInputType.number,
                  validator: _stockValidator,
                ),
                _AppTextField(
                  label: 'Tripoli Branch Stock',
                  hint: '0',
                  controller: _tripoliStockController,
                  keyboardType: TextInputType.number,
                  validator: _stockValidator,
                ),
                _AppTextField(
                  label: 'Saida Branch Stock',
                  hint: '0',
                  controller: _saidaStockController,
                  keyboardType: TextInputType.number,
                  validator: _stockValidator,
                ),
              ],
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
import 'dart:io';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/repositories/supplier_category_repository.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/domain/repositories/branch_inventory_repository.dart';
import '../../../branches/domain/repositories/branch_repository.dart';
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
  final BranchRepository _branchRepository = sl<BranchRepository>();
  final BranchInventoryRepository _branchInventoryRepository =
      sl<BranchInventoryRepository>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minimumOrderQuantityController = TextEditingController(text: '10');
  final _quickInitialStockController = TextEditingController();
  final _branchStockSearchController = TextEditingController();

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
  bool _isLoadingInitialStockBranches = false;
  bool _isAdvancedInitialStockMode = false;

  List<SupplierCategoryEntity> _categories = [];
  List<SupplierSubCategoryEntity> _subCategories = [];
  List<BranchEntity> _initialStockBranches = [];
  final Map<String, TextEditingController> _initialStockControllers = {};
  final Set<String> _selectedInitialStockBranchIds = {};

  @override
  void initState() {
    super.initState();
    _branchStockSearchController.addListener(_refreshInitialStockUi);

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

    if (!widget.isEditMode) {
      _loadInitialStockBranches();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minimumOrderQuantityController.dispose();
    _quickInitialStockController.dispose();
    _branchStockSearchController.dispose();
    for (final controller in _initialStockControllers.values) {
      controller.dispose();
    }
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

  Future<void> _loadInitialStockBranches() async {
    setState(() {
      _isLoadingInitialStockBranches = true;
    });

    try {
      final branches = await _branchRepository.getBranches();

      if (!mounted) return;

      for (final controller in _initialStockControllers.values) {
        controller.dispose();
      }
      _initialStockControllers.clear();
      _selectedInitialStockBranchIds.clear();

      for (final branch in branches) {
        final controller = TextEditingController();
        controller.addListener(_refreshInitialStockUi);
        _initialStockControllers[branch.id] = controller;
      }

      setState(() {
        _initialStockBranches = branches;
        _isLoadingInitialStockBranches = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _initialStockBranches = [];
        _isLoadingInitialStockBranches = false;
      });

      _showError(e);
    }
  }

  void _refreshInitialStockUi() {
    if (!mounted) return;
    setState(() {});
  }

  int _initialStockTotal() {
    var total = 0;

    for (final branchId in _selectedInitialStockBranchIds) {
      final value = _initialStockControllers[branchId]?.text.trim() ?? '';
      final quantity = int.tryParse(value) ?? 0;

      if (quantity > 0) {
        total += quantity;
      }
    }

    return total;
  }

  List<BranchEntity> _visibleInitialStockBranches() {
    final query = _branchStockSearchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      return _initialStockBranches
          .where((branch) {
            final name = branch.name.toLowerCase();
            final city = branch.city.toLowerCase();
            final location = branch.locationLabel.toLowerCase();

            return name.contains(query) ||
                city.contains(query) ||
                location.contains(query);
          })
          .take(20)
          .toList();
    }

    final selected = _initialStockBranches
        .where((branch) => _selectedInitialStockBranchIds.contains(branch.id))
        .toList();

    final remainingLimit = 8 - selected.length;
    final remaining = remainingLimit <= 0
        ? <BranchEntity>[]
        : _initialStockBranches
            .where((branch) => !_selectedInitialStockBranchIds.contains(branch.id))
            .take(remainingLimit)
            .toList();

    return [...selected, ...remaining];
  }

  void _setInitialStockMode(bool advanced) {
    setState(() {
      _isAdvancedInitialStockMode = advanced;
    });
  }

  void _toggleInitialStockBranch(String branchId, bool selected) {
    setState(() {
      if (selected) {
        _selectedInitialStockBranchIds.add(branchId);
      } else {
        _selectedInitialStockBranchIds.remove(branchId);
        _initialStockControllers[branchId]?.clear();
      }
    });
  }

  void _clearInitialStockSelection() {
    setState(() {
      _selectedInitialStockBranchIds.clear();
      _quickInitialStockController.clear();
      _branchStockSearchController.clear();

      for (final controller in _initialStockControllers.values) {
        controller.clear();
      }
    });
  }

  void _applyQuickInitialStockToAllBranches() {
    final value = _quickInitialStockController.text.trim();
    final quantity = int.tryParse(value);

    if (_initialStockBranches.isEmpty) {
      AppToast.error(context, context.l10n.createBranchFirst);
      return;
    }

    if (quantity == null || quantity < 0) {
      AppToast.error(context, 'Please enter a valid stock quantity.');
      return;
    }

    if (quantity > 1000000) {
      AppToast.error(context, 'Stock quantity is too high.');
      return;
    }

    setState(() {
      _selectedInitialStockBranchIds.clear();

      for (final branch in _initialStockBranches) {
        _selectedInitialStockBranchIds.add(branch.id);
        _initialStockControllers[branch.id]?.text = quantity.toString();
      }
    });
  }

  Map<String, int>? _readInitialStockAssignments() {
    final assignments = <String, int>{};

    for (final branchId in _selectedInitialStockBranchIds) {
      final branch = _initialStockBranches
          .where((item) => item.id == branchId)
          .cast<BranchEntity?>()
          .firstWhere((item) => item != null, orElse: () => null);

      if (branch == null) continue;

      final value = _initialStockControllers[branchId]?.text.trim() ?? '';

      if (value.isEmpty) continue;

      final quantity = int.tryParse(value);

      if (quantity == null || quantity < 0) {
        AppToast.error(
          context,
          'Please enter a valid stock quantity for ${branch.name}.',
        );
        return null;
      }

      if (quantity > 1000000) {
        AppToast.error(
          context,
          'Stock quantity is too high for ${branch.name}.',
        );
        return null;
      }

      if (quantity > 0) {
        assignments[branchId] = quantity;
      }
    }

    return assignments;
  }

  Future<int> _assignInitialStockToBranches({
    required String productId,
    required Map<String, int> assignments,
  }) async {
    var assignedCount = 0;

    for (final entry in assignments.entries) {
      await _branchInventoryRepository.assignProductToBranch(
        branchId: entry.key,
        productId: productId,
        stockQuantity: entry.value,
      );
      assignedCount++;
    }

    return assignedCount;
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
    // Do not pass maxWidth/maxHeight/imageQuality: image_picker's native
    // resize bakes a green cast into wide-gamut (Display P3) iOS photos.
    // The backend downscales and re-encodes the image to clean sRGB instead.
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
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

      AppToast.success(context, context.l10n.categoryAddedMessage(category.name));
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
      AppToast.error(context, context.l10n.selectCategoryFirstMessage);
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

      AppToast.success(
        context,
        context.l10n.subCategoryAddedMessage(subCategory.name),
      );
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
      AppToast.error(context, context.l10n.selectCategoryFirstMessage);
      return;
    }

    final selectedCategory = _categories
        .where((category) => category.id == _selectedCategoryId)
        .cast<SupplierCategoryEntity?>()
        .firstWhere((category) => category != null, orElse: () => null);

    if (selectedCategory == null) {
      AppToast.error(context, context.l10n.selectedCategoryNotFound);
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

      AppToast.success(
        context,
        context.l10n.categoryDeletedMessage(selectedCategory.name),
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
      AppToast.error(context, context.l10n.selectSubCategoryFirstMessage);
      return;
    }

    final selectedSubCategory = _subCategories
        .where((subCategory) => subCategory.id == _selectedSubCategoryId)
        .cast<SupplierSubCategoryEntity?>()
        .firstWhere((subCategory) => subCategory != null, orElse: () => null);

    if (selectedSubCategory == null) {
      AppToast.error(context, context.l10n.selectedSubCategoryNotFound);
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

      AppToast.success(
        context,
        context.l10n.subCategoryDeletedMessage(selectedSubCategory.name),
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

    final initialStockAssignments = widget.isEditMode
        ? <String, int>{}
        : _readInitialStockAssignments();

    if (initialStockAssignments == null) return;

    final selectedCategory = _categories
        .where((category) => category.id == _selectedCategoryId)
        .cast<SupplierCategoryEntity?>()
        .firstWhere((category) => category != null, orElse: () => null);

    if (selectedCategory == null) {
      AppToast.error(context, context.l10n.selectedCategoryNotFound);
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

          // If supplier selected a new local image, this path will be uploaded.
          // If not, this remains the old backend image path from productToEdit.
          imagePath: _selectedImagePath,

          // Important:
          // Keep old product image when editing without selecting a new image.
          existingImageUrl: widget.productToEdit?.imagePath,
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

        if (initialStockAssignments.isNotEmpty) {
          try {
            await _assignInitialStockToBranches(
              productId: product.id,
              assignments: initialStockAssignments,
            );
          } catch (stockError) {
            if (!mounted) return;

            setState(() {
              _isSavingProduct = false;
            });

            AppToast.warning(
              context,
              'Product was saved, but initial branch stock was not fully saved. Please open Product Branch Stock to complete it.',
            );

            context.pop(product);
            return;
          }
        }
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
    AppToast.error(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = widget.isEditMode ? context.l10n.editProductTitle : context.l10n.addProductTitle;
    final buttonText = widget.isEditMode ? context.l10n.updateProductButton : context.l10n.saveProductButton;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
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
                        label: '${context.l10n.pricePerUnitLabel} (${CurrencyFormatter.code(context)} (${CurrencyFormatter.symbol(context)}))',
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
                  if (widget.isEditMode)
                    _InventoryManagedInfoCard(
                      isEditMode: widget.isEditMode,
                      product: widget.productToEdit,
                    )
                  else
                    _InitialBranchStockSection(
                      branches: _initialStockBranches,
                      visibleBranches: _visibleInitialStockBranches(),
                      controllers: _initialStockControllers,
                      quickStockController: _quickInitialStockController,
                      searchController: _branchStockSearchController,
                      selectedBranchIds: _selectedInitialStockBranchIds,
                      totalStock: _initialStockTotal(),
                      isAdvancedMode: _isAdvancedInitialStockMode,
                      isLoading: _isLoadingInitialStockBranches,
                      onReload: _loadInitialStockBranches,
                      onModeChanged: _setInitialStockMode,
                      onApplyQuickStock: _applyQuickInitialStockToAllBranches,
                      onClear: _clearInitialStockSelection,
                      onBranchSelected: _toggleInitialStockBranch,
                    ),
                ],
              ),
            ),
      ),
    );
  }
}




class _InitialBranchStockSection extends StatefulWidget {
  final List<BranchEntity> branches;
  final List<BranchEntity> visibleBranches;
  final Map<String, TextEditingController> controllers;
  final TextEditingController quickStockController;
  final TextEditingController searchController;
  final Set<String> selectedBranchIds;
  final int totalStock;
  final bool isAdvancedMode;
  final bool isLoading;
  final VoidCallback onReload;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onApplyQuickStock;
  final VoidCallback onClear;
  final void Function(String branchId, bool selected) onBranchSelected;

  _InitialBranchStockSection({
    required this.branches,
    required this.visibleBranches,
    required this.controllers,
    required this.quickStockController,
    required this.searchController,
    required this.selectedBranchIds,
    required this.totalStock,
    required this.isAdvancedMode,
    required this.isLoading,
    required this.onReload,
    required this.onModeChanged,
    required this.onApplyQuickStock,
    required this.onClear,
    required this.onBranchSelected,
  });

  @override
  State<_InitialBranchStockSection> createState() =>
      _InitialBranchStockSectionState();
}

class _InitialBranchStockSectionState extends State<_InitialBranchStockSection> {
  static const String _allBranchesValue = '__all_branches__';
  static const String _multipleBranchesValue = '__multiple_branches__';

  bool _isOpen = false;
  String _selectedTarget = _allBranchesValue;

  @override
  void initState() {
    super.initState();
    widget.quickStockController.addListener(_safeRefresh);
    widget.searchController.addListener(_safeRefresh);
  }

  @override
  void didUpdateWidget(covariant _InitialBranchStockSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.quickStockController != widget.quickStockController) {
      oldWidget.quickStockController.removeListener(_safeRefresh);
      widget.quickStockController.addListener(_safeRefresh);
    }

    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController.removeListener(_safeRefresh);
      widget.searchController.addListener(_safeRefresh);
    }

    final isBuiltInTarget = _selectedTarget == _allBranchesValue ||
        _selectedTarget == _multipleBranchesValue;

    if (!isBuiltInTarget &&
        !widget.branches.any((branch) => branch.id == _selectedTarget)) {
      _selectedTarget = _allBranchesValue;
    }
  }

  @override
  void dispose() {
    widget.quickStockController.removeListener(_safeRefresh);
    widget.searchController.removeListener(_safeRefresh);
    super.dispose();
  }

  void _safeRefresh() {
    if (!mounted) return;
    setState(() {});
  }

  int? _typedQuantity() {
    final value = widget.quickStockController.text.trim();
    if (value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  void _changeTarget(String value) {
    FocusScope.of(context).unfocus();

    widget.onClear();
    widget.searchController.clear();

    setState(() {
      _selectedTarget = value;
    });
  }

  void _applyStock() {
    final quantity = _typedQuantity();

    if (quantity == null) {
      AppToast.error(context, 'Please enter stock greater than 0');
      return;
    }

    if (widget.branches.isEmpty) {
      widget.onReload();
      return;
    }

    FocusScope.of(context).unfocus();

    if (_selectedTarget == _allBranchesValue) {
      widget.onApplyQuickStock();
      setState(() {});
      return;
    }

    if (_selectedTarget == _multipleBranchesValue) {
      AppToast.info(context, 'Choose branches and set each stock quantity below.');
      return;
    }

    widget.onClear();
    widget.quickStockController.text = quantity.toString();
    widget.onBranchSelected(_selectedTarget, true);
    widget.controllers[_selectedTarget]?.text = quantity.toString();

    setState(() {});
  }

  void _clearStock() {
    FocusScope.of(context).unfocus();
    widget.onClear();
    setState(() {
      _selectedTarget = _allBranchesValue;
    });
  }

  String _targetLabel(String value) {
    if (value == _allBranchesValue) return 'All branches';
    if (value == _multipleBranchesValue) return 'Multiple branches';

    BranchEntity? branch;
    for (final item in widget.branches) {
      if (item.id == value) {
        branch = item;
        break;
      }
    }

    if (branch == null) return 'Selected branch';

    final location = branch.locationLabel.trim();
    if (location.isEmpty) return branch.name;
    return '${branch.name} • $location';
  }

  List<DropdownMenuItem<String>> _branchItems() {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: _allBranchesValue,
        child: Text(
          'All branches',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DropdownMenuItem<String>(
        value: _multipleBranchesValue,
        child: Text(
          'Multiple branches',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    for (final branch in widget.branches) {
      items.add(
        DropdownMenuItem<String>(
          value: branch.id,
          child: Text(
            _targetLabel(branch.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return items;
  }

  List<BranchEntity> _selectedBranchesPreview() {
    return widget.branches
        .where((branch) => widget.selectedBranchIds.contains(branch.id))
        .take(4)
        .toList();
  }

  List<BranchEntity> _multipleBranchList() {
    final query = widget.searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      final selected = widget.branches
          .where((branch) => widget.selectedBranchIds.contains(branch.id))
          .toList();

      final remaining = widget.branches
          .where((branch) => !widget.selectedBranchIds.contains(branch.id))
          .take(8)
          .toList();

      return [...selected, ...remaining];
    }

    return widget.branches.where((branch) {
      final name = branch.name.toLowerCase();
      final city = branch.city.toLowerCase();
      final location = branch.locationLabel.toLowerCase();

      return name.contains(query) ||
          city.contains(query) ||
          location.contains(query);
    }).take(12).toList();
  }

  Widget _outlinedFieldDecorationWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: child,
    );
  }

  Widget _buildTargetPicker(Color primaryColor) {
    return DropdownButtonFormField<String>(
      value: _selectedTarget,
      isExpanded: true,
      items: _branchItems(),
      onChanged: (value) {
        if (value == null || value == _selectedTarget) return;
        _changeTarget(value);
      },
      decoration: InputDecoration(
        labelText: 'Stock target',
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppThemeTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppThemeTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildSingleStockInput(Color primaryColor) {
    final quantity = _typedQuantity();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.quickStockController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Stock quantity',
            hintText: 'Example: 50',
            prefixIcon: Icon(Icons.inventory_rounded, size: 20),
            filled: true,
            fillColor: AppThemeTokens.inputFill,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppThemeTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppThemeTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: quantity == null ? null : _applyStock,
            icon: Icon(Icons.check_rounded, size: 18),
            label: Text(
              _selectedTarget == _allBranchesValue
                  ? 'Apply to all branches'
                  : 'Apply to selected branch',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleBranchEditor(Color primaryColor) {
    final branches = _multipleBranchList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search branches',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
            suffixIcon: widget.searchController.text.trim().isEmpty
                ? null
                : IconButton(
                    onPressed: () => widget.searchController.clear(),
                    icon: Icon(Icons.close_rounded, size: 18),
                  ),
            filled: true,
            fillColor: AppThemeTokens.inputFill,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppThemeTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppThemeTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                '${widget.selectedBranchIds.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearStock,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Clear',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        if (branches.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeTokens.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Text(
              'No branches found.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: branches
                .map((branch) => _MultipleInitialStockBranchRow(
                      branch: branch,
                      controller: widget.controllers[branch.id],
                      isSelected:
                          widget.selectedBranchIds.contains(branch.id),
                      primaryColor: primaryColor,
                      onSelectedChanged: (selected) {
                        widget.onBranchSelected(branch.id, selected);
                      },
                    ))
                .toList(),
          ),
        SizedBox(height: 8),
        Text(
          'Branches not selected or with stock 0 will stay without initial stock.',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hasStock = widget.selectedBranchIds.isNotEmpty && widget.totalStock > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasStock
                          ? 'Initial stock: ${widget.totalStock}'
                          : 'Initial stock is optional',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      hasStock
                          ? '${widget.selectedBranchIds.length} branch${widget.selectedBranchIds.length == 1 ? '' : 'es'} selected'
                          : 'Add stock now or update it later from Product Branch Stock.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        if (widget.branches.isEmpty) {
                          widget.onReload();
                          return;
                        }
                        setState(() => _isOpen = !_isOpen);
                      },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  widget.isLoading
                      ? 'Loading'
                      : widget.branches.isEmpty
                          ? 'Reload'
                          : _isOpen
                              ? 'Hide'
                              : 'Set',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (widget.isLoading) ...[
            SizedBox(height: 12),
            LinearProgressIndicator(minHeight: 3),
          ],
          if (_isOpen && !widget.isLoading && widget.branches.isNotEmpty) ...[
            SizedBox(height: 14),
            Text(
              'Choose where this initial stock should be saved. Stock will still be stored in Branch Inventory, not inside Product.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textSecondary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 12),
            _buildTargetPicker(primaryColor),
            SizedBox(height: 10),
            if (_selectedTarget == _multipleBranchesValue)
              _buildMultipleBranchEditor(primaryColor)
            else
              _buildSingleStockInput(primaryColor),
          ],
          if (hasStock) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeTokens.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.totalStock} total stock prepared',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppThemeTokens.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearStock,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedBranchesPreview().isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      _selectedBranchesPreview()
                          .map((branch) => branch.name)
                          .join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MultipleInitialStockBranchRow extends StatelessWidget {
  final BranchEntity branch;
  final TextEditingController? controller;
  final bool isSelected;
  final Color primaryColor;
  final ValueChanged<bool> onSelectedChanged;

  _MultipleInitialStockBranchRow({
    required this.branch,
    required this.controller,
    required this.isSelected,
    required this.primaryColor,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? primaryColor : AppThemeTokens.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectedChanged(value ?? false),
              activeColor: primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  branch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  branch.locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: TextField(
              controller: controller,
              enabled: isSelected,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppThemeTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppThemeTokens.border),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppThemeTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
          ),
        ],
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
        isExpanded: true,
        value: safeSelectedCategoryId,
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return categories.map((category) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            );
          }).toList();
        },
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
        isExpanded: true,
        value: safeSelectedSubCategoryId,
        items: subCategories.map((subCategory) {
          return DropdownMenuItem<String>(
            value: subCategory.id,
            child: Text(
              subCategory.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return subCategories.map((subCategory) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                subCategory.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            );
          }).toList();
        },
        onChanged: isEnabled ? onChanged : null,
        decoration: _dropdownDecoration(
          isLoading
              ? context.l10n.loadingSubCategories
              : isEnabled
                  ? context.l10n.selectSubCategoryIfNeeded
                  : context.l10n.selectCategoryFirstMessage,
        ),
      ),
      addButtonText:
          isCreatingSubCategory ? context.l10n.addingLabel : context.l10n.addSubCategoryTitle,
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

  const _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedStatus == ProductStatus.active;
    final statusLabel = isActive
        ? context.l10n.activeStatus
        : context.l10n.inactiveStatus;
    final statusColor = isActive
        ? Theme.of(context).colorScheme.primary
        : AppThemeTokens.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productStatusLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isActive,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  onChanged(value ? ProductStatus.active : ProductStatus.inactive);
                },
              ),
            ],
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
      padding: EdgeInsets.all(18),
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
              fontSize: 18,
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


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/supplier_category_entity.dart';
import '../../domain/entities/supplier_sub_category_entity.dart';
import '../bloc/supplier_catalog/supplier_catalog_bloc.dart';
import '../bloc/supplier_catalog/supplier_catalog_event.dart';
import '../bloc/supplier_catalog/supplier_catalog_state.dart';
import '../widgets/catalog_card.dart';
import '../widgets/catalog_search_box.dart';
import '../widgets/empty_catalog_message.dart';

class SupplierCatalogScreen extends StatefulWidget {
  const SupplierCatalogScreen({super.key});

  @override
  State<SupplierCatalogScreen> createState() => _SupplierCatalogScreenState();
}

class _SupplierCatalogScreenState extends State<SupplierCatalogScreen>
    with SingleTickerProviderStateMixin {
  final SupplierCatalogBloc _catalogBloc = sl<SupplierCatalogBloc>();

  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _subCategorySearchController =
      TextEditingController();

  late final TabController _tabController;

  String _categoryQuery = '';
  String _subCategoryQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _catalogBloc.add(const LoadSupplierCatalog());
  }

  @override
  void dispose() {
    _catalogBloc.close();
    _tabController.dispose();
    _categorySearchController.dispose();
    _subCategorySearchController.dispose();
    super.dispose();
  }

  List<SupplierCategoryEntity> _filteredCategories(
    List<SupplierCategoryEntity> categories,
  ) {
    final query = _categoryQuery.trim().toLowerCase();

    if (query.isEmpty) return categories;

    return categories.where((category) {
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  List<SupplierSubCategoryEntity> _filteredSubCategories(
    List<SupplierSubCategoryEntity> subCategories,
  ) {
    final query = _subCategoryQuery.trim().toLowerCase();

    if (query.isEmpty) return subCategories;

    return subCategories.where((subCategory) {
      return subCategory.name.toLowerCase().contains(query) ||
          subCategory.categoryName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _showCategoryDialog({
    SupplierCategoryEntity? category,
  }) async {
    final isEdit = category != null;
    final controller = TextEditingController(text: category?.name ?? '');

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit ? 'Edit Category' : 'Add Category',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category name',
              hintText: 'Example: Clothing',
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

                if (value.isEmpty) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );

    if (name == null) return;

    if (isEdit) {
      _catalogBloc.add(
        UpdateCatalogCategoryRequested(
          categoryId: category.id,
          name: name,
        ),
      );
    } else {
      _catalogBloc.add(
        CreateCatalogCategoryRequested(name: name),
      );
    }
  }

  Future<void> _showSubCategoryDialog({
    required List<SupplierCategoryEntity> categories,
    SupplierSubCategoryEntity? subCategory,
  }) async {
    final activeCategories =
        categories.where((category) => category.isActive).toList();

    if (activeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create an active category first'),
        ),
      );
      return;
    }

    final isEdit = subCategory != null;

    String selectedCategoryId =
        subCategory?.categoryId ?? activeCategories.first.id;

    final controller = TextEditingController(text: subCategory?.name ?? '');

    final result = await showDialog<_SubCategoryDialogResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Sub Category' : 'Add Sub Category',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      items: activeCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: isEdit
                          ? null
                          : (value) {
                              if (value == null) return;

                              setDialogState(() {
                                selectedCategoryId = value;
                              });
                            },
                      decoration: const InputDecoration(
                        labelText: 'Parent category',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Sub category name',
                        hintText: 'Example: Women Clothing',
                      ),
                    ),
                  ],
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

                    if (value.isEmpty) return;

                    Navigator.of(dialogContext).pop(
                      _SubCategoryDialogResult(
                        categoryId: selectedCategoryId,
                        name: value,
                      ),
                    );
                  },
                  child: Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    if (isEdit) {
      _catalogBloc.add(
        UpdateCatalogSubCategoryRequested(
          subCategoryId: subCategory.id,
          name: result.name,
        ),
      );
    } else {
      _catalogBloc.add(
        CreateCatalogSubCategoryRequested(
          categoryId: result.categoryId,
          name: result.name,
        ),
      );
    }
  }

  Future<void> _toggleCategoryStatus(
    SupplierCategoryEntity category,
  ) async {
    final newStatus = category.isActive
        ? SupplierCatalogStatus.inactive
        : SupplierCatalogStatus.active;

    final shouldContinue = await _confirmAction(
      title: category.isActive ? 'Deactivate Category' : 'Activate Category',
      message: category.isActive
          ? 'This category will no longer appear when adding new products. Existing products will not be affected.'
          : 'This category will appear again when adding new products.',
      confirmText: category.isActive ? 'Deactivate' : 'Activate',
    );

    if (shouldContinue != true) return;

    _catalogBloc.add(
      UpdateCatalogCategoryStatusRequested(
        categoryId: category.id,
        status: newStatus,
      ),
    );
  }

  Future<void> _toggleSubCategoryStatus(
    SupplierSubCategoryEntity subCategory,
  ) async {
    final newStatus = subCategory.isActive
        ? SupplierCatalogStatus.inactive
        : SupplierCatalogStatus.active;

    final shouldContinue = await _confirmAction(
      title: subCategory.isActive
          ? 'Deactivate Sub Category'
          : 'Activate Sub Category',
      message: subCategory.isActive
          ? 'This sub category will no longer appear when adding new products. Existing products will not be affected.'
          : 'This sub category will appear again when adding new products.',
      confirmText: subCategory.isActive ? 'Deactivate' : 'Activate',
    );

    if (shouldContinue != true) return;

    _catalogBloc.add(
      UpdateCatalogSubCategoryStatusRequested(
        subCategoryId: subCategory.id,
        status: newStatus,
      ),
    );
  }

  Future<void> _deleteCategory(SupplierCategoryEntity category) async {
    final shouldDelete = await _confirmAction(
      title: 'Delete Category',
      message:
          'Delete "${category.name}" permanently? This is allowed only if it is not linked to products or sub categories.',
      confirmText: 'Delete',
      isDanger: true,
    );

    if (shouldDelete != true) return;

    _catalogBloc.add(
      DeleteCatalogCategoryRequested(categoryId: category.id),
    );
  }

  Future<void> _deleteSubCategory(
    SupplierSubCategoryEntity subCategory,
  ) async {
    final shouldDelete = await _confirmAction(
      title: 'Delete Sub Category',
      message:
          'Delete "${subCategory.name}" permanently? This is allowed only if it is not linked to products.',
      confirmText: 'Delete',
      isDanger: true,
    );

    if (shouldDelete != true) return;

    _catalogBloc.add(
      DeleteCatalogSubCategoryRequested(subCategoryId: subCategory.id),
    );
  }

  Future<bool?> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: isDanger
                  ? ElevatedButton.styleFrom(
                      backgroundColor: AppThemeTokens.error,
                      foregroundColor: Colors.white,
                    )
                  : null,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _handleBackOrDrawer(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    Scaffold.of(context).openDrawer();
  }

  IconData _leadingIcon(BuildContext context) {
    return context.canPop() ? Icons.arrow_back_ios_new_rounded : Icons.menu;
  }

  String _leadingTooltip(BuildContext context) {
    return context.canPop() ? 'Back' : 'Menu';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierCatalogBloc>.value(
      value: _catalogBloc,
      child: BlocListener<SupplierCatalogBloc, SupplierCatalogState>(
        listenWhen: (previous, current) {
          return previous.error != current.error ||
              previous.successMessage != current.successMessage;
        },
        listener: (context, state) {
          if (state.error != null && state.error!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }

          if (state.successMessage != null &&
              state.successMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        child: BlocBuilder<SupplierCatalogBloc, SupplierCatalogState>(
          builder: (context, state) {
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Scaffold(
              backgroundColor: AppThemeTokens.background,
              drawer: const SupplierAppDrawer(),
              appBar: AppBar(
                backgroundColor: AppThemeTokens.background,
                elevation: 0,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      tooltip: _leadingTooltip(context),
                      onPressed: () => _handleBackOrDrawer(context),
                      icon: Icon(_leadingIcon(context)),
                    );
                  },
                ),
                title: const Text(
                  'Catalog Management',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: state.isLoading || state.isSaving
                        ? null
                        : () => _catalogBloc.add(
                              const RefreshSupplierCatalog(),
                            ),
                    icon: Icon(Icons.refresh, color: primaryColor),
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: AppThemeTokens.textSecondary,
                  indicatorColor: primaryColor,
                  tabs: const [
                    Tab(text: 'Categories'),
                    Tab(text: 'Sub Categories'),
                  ],
                ),
              ),
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCategoriesTab(state),
                            _buildSubCategoriesTab(state),
                          ],
                        ),
                        if (state.isSaving)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Color(0x22000000),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: state.isSaving
                    ? null
                    : () {
                        if (_tabController.index == 0) {
                          _showCategoryDialog();
                        } else {
                          _showSubCategoryDialog(
                            categories: state.categories,
                          );
                        }
                      },
                icon: const Icon(Icons.add),
                label: Text(
                  _tabController.index == 0
                      ? 'Add Category'
                      : 'Add Sub Category',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(SupplierCatalogState state) {
    final categories = _filteredCategories(state.categories);

    return Column(
      children: [
        CatalogSearchBox(
          controller: _categorySearchController,
          hintText: 'Search categories...',
          onChanged: (value) {
            setState(() {
              _categoryQuery = value;
            });
          },
        ),
        Expanded(
          child: categories.isEmpty
              ? const EmptyCatalogMessage(message: 'No categories found')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return CatalogCard(
                      title: category.name,
                      subtitle:
                          '${category.productCount} products • ${category.subCategoryCount} sub categories',
                      isActive: category.isActive,
                      canDelete: category.canDelete,
                      onEdit: () => _showCategoryDialog(category: category),
                      onToggleStatus: () => _toggleCategoryStatus(category),
                      onDelete: () => _deleteCategory(category),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubCategoriesTab(SupplierCatalogState state) {
    final subCategories = _filteredSubCategories(state.subCategories);

    return Column(
      children: [
        CatalogSearchBox(
          controller: _subCategorySearchController,
          hintText: 'Search sub categories...',
          onChanged: (value) {
            setState(() {
              _subCategoryQuery = value;
            });
          },
        ),
        Expanded(
          child: subCategories.isEmpty
              ? const EmptyCatalogMessage(message: 'No sub categories found')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final subCategory = subCategories[index];

                    return CatalogCard(
                      title: subCategory.name,
                      subtitle:
                          '${subCategory.categoryName} • ${subCategory.productCount} products',
                      isActive: subCategory.isActive,
                      canDelete: subCategory.canDelete,
                      onEdit: () => _showSubCategoryDialog(
                        categories: state.categories,
                        subCategory: subCategory,
                      ),
                      onToggleStatus: () =>
                          _toggleSubCategoryStatus(subCategory),
                      onDelete: () => _deleteSubCategory(subCategory),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SubCategoryDialogResult {
  final String categoryId;
  final String name;

  const _SubCategoryDialogResult({
    required this.categoryId,
    required this.name,
  });
}

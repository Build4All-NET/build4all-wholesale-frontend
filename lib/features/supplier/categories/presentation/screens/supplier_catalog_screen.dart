import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

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
  SupplierCatalogScreen({super.key});

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

    _catalogBloc.add(LoadSupplierCatalog());
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
            isEdit ? context.l10n.editCategoryTitle : context.l10n.addCategoryTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.l10n.categoryNameFieldLabel,
              hintText: context.l10n.categoryNameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(isEdit ? context.l10n.updateButton : context.l10n.addButton),
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
      AppToast.error(context, context.l10n.createActiveCategoryFirst);
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
                isEdit ? context.l10n.editSubCategoryTitle : context.l10n.addSubCategoryTitle,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
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
                      decoration: InputDecoration(
                        labelText: context.l10n.parentCategoryLabel,
                      ),
                    ),
                    SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.subCategoryNameFieldLabel,
                        hintText: context.l10n.subCategoryNameHint,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.l10n.cancel),
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
                  child: Text(isEdit ? context.l10n.updateButton : context.l10n.addButton),
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
      title: category.isActive ? context.l10n.deactivateCategoryTitle : context.l10n.activateCategoryTitle,
      message: category.isActive
          ? context.l10n.deactivateCategoryMessage
          : context.l10n.activateCategoryMessage,
      confirmText: category.isActive ? context.l10n.deactivateButton : context.l10n.activateButton,
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
          ? context.l10n.deactivateSubCategoryTitle
          : context.l10n.activateSubCategoryTitle,
      message: subCategory.isActive
          ? context.l10n.deactivateSubCategoryMessage
          : context.l10n.activateSubCategoryMessage,
      confirmText: subCategory.isActive ? context.l10n.deactivateButton : context.l10n.activateButton,
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
      title: context.l10n.deleteCategoryTitle,
      message:
          context.l10n.deleteCategoryPermanentConfirmation(category.name),
      confirmText: context.l10n.delete,
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
      title: context.l10n.deleteSubCategoryTitle,
      message:
          context.l10n.deleteSubCategoryPermanentConfirmation(subCategory.name),
      confirmText: context.l10n.delete,
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
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
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
    return context.canPop() ? context.l10n.backButton : context.l10n.menuTooltip;
  }


  String _localizedSuccessMessage(BuildContext context, String message) {
    switch (message) {
      case 'categoryAdded':
      case 'Category added':
        return context.l10n.categoryAddedSuccessfully;
      case 'categoryUpdated':
      case 'Category updated':
        return context.l10n.categoryUpdatedSuccessfully;
      case 'categoryStatusUpdated':
      case 'Category status updated':
        return context.l10n.categoryStatusUpdatedSuccessfully;
      case 'categoryDeleted':
      case 'Category deleted':
        return context.l10n.categoryDeletedSuccessfully;
      case 'subCategoryAdded':
      case 'Sub category added':
        return context.l10n.subCategoryAddedSuccessfully;
      case 'subCategoryUpdated':
      case 'Sub category updated':
        return context.l10n.subCategoryUpdatedSuccessfully;
      case 'subCategoryStatusUpdated':
      case 'Sub category status updated':
        return context.l10n.subCategoryStatusUpdatedSuccessfully;
      case 'subCategoryDeleted':
      case 'Sub category deleted':
        return context.l10n.subCategoryDeletedSuccessfully;
      default:
        return message;
    }
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
            AppToast.error(context, state.error!);
          }

          if (state.successMessage != null &&
              state.successMessage!.trim().isNotEmpty) {
            AppToast.success(
              context,
              _localizedSuccessMessage(context, state.successMessage!),
            );
          }
        },
        child: BlocBuilder<SupplierCatalogBloc, SupplierCatalogState>(
          builder: (context, state) {
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Scaffold(
              backgroundColor: AppThemeTokens.background,
              drawer: SupplierAppDrawer(),
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
                title: Text(
                  context.l10n.catalogTitle,
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
                              RefreshSupplierCatalog(),
                            ),
                    icon: Icon(Icons.refresh, color: primaryColor),
                  ),
                  SizedBox(width: 8),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: AppThemeTokens.textSecondary,
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(text: context.l10n.categoriesTab),
                    Tab(text: context.l10n.subCategoriesTab),
                  ],
                ),
              ),
              body: state.isLoading
                  ? Center(child: CircularProgressIndicator())
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
                          Positioned.fill(
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
                icon: Icon(Icons.add),
                label: Text(
                  _tabController.index == 0
                      ? context.l10n.addCategoryTitle
                      : context.l10n.addSubCategoryTitle,
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
          hintText: context.l10n.searchCategoriesHint,
          onChanged: (value) {
            setState(() {
              _categoryQuery = value;
            });
          },
        ),
        Expanded(
          child: categories.isEmpty
              ? EmptyCatalogMessage(message: context.l10n.noCategoriesFound)
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return CatalogCard(
                      title: category.name,
                      subtitle:
                          context.l10n.categoryStats(category.productCount, category.subCategoryCount),
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
          hintText: context.l10n.searchSubCategoriesHint,
          onChanged: (value) {
            setState(() {
              _subCategoryQuery = value;
            });
          },
        ),
        Expanded(
          child: subCategories.isEmpty
              ? EmptyCatalogMessage(message: context.l10n.noSubCategoriesFound)
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final subCategory = subCategories[index];

                    return CatalogCard(
                      title: subCategory.name,
                      subtitle:
                          context.l10n.subCategoryStats(subCategory.categoryName, subCategory.productCount),
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

  _SubCategoryDialogResult({
    required this.categoryId,
    required this.name,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/promotion_entity.dart';
import '../bloc/promotions_bloc.dart';
import '../bloc/promotions_event.dart';
import '../bloc/promotions_state.dart';

class CreatePromotionScreen extends StatelessWidget {
  final PromotionEntity? promotion;

  const CreatePromotionScreen({
    super.key,
    this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromotionsBloc>(
      create: (_) => sl<PromotionsBloc>(),
      child: _CreatePromotionView(promotion: promotion),
    );
  }
}

class _CreatePromotionView extends StatefulWidget {
  final PromotionEntity? promotion;

  const _CreatePromotionView({
    this.promotion,
  });

  @override
  State<_CreatePromotionView> createState() => _CreatePromotionViewState();
}

class _CreatePromotionViewState extends State<_CreatePromotionView> {
  final _formKey = GlobalKey<FormState>();

  final _lookupService = _PromotionLookupService(
    sl<ApiClient>(instanceName: 'projectApiClient'),
  );

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _minOrderAmountController;
  late final TextEditingController _maxDiscountAmountController;

  PromotionDiscountType _discountType = PromotionDiscountType.percent;
  PromotionTargetType _targetType = PromotionTargetType.allProducts;
  PromotionBranchScope _branchScope = PromotionBranchScope.allBranches;

  String? _selectedTargetId;
  String? _selectedTargetName;
  String? _selectedTargetCategoryId;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  bool _active = true;

  bool _loadingTargets = true;
  bool _loadingBranches = true;

  String? _targetErrorMessage;
  String? _branchErrorMessage;

  final List<_PromotionLookupOption> _products = [];
  final List<_PromotionLookupOption> _categories = [];
  final List<_PromotionLookupOption> _subCategories = [];
  final List<_PromotionLookupOption> _branches = [];

  final List<String> _selectedBranchIds = [];
  final List<String> _selectedBranchNames = [];

  bool get _isEditMode => widget.promotion != null;

  bool get _isPercent => _discountType == PromotionDiscountType.percent;

  @override
  void initState() {
    super.initState();

    final promotion = widget.promotion;

    _titleController = TextEditingController(text: promotion?.title ?? '');
    _descriptionController = TextEditingController(
      text: promotion?.description ?? '',
    );
    _discountValueController = TextEditingController(
      text: promotion == null ? '' : promotion.discountValue.toString(),
    );
    _minOrderAmountController = TextEditingController(
      text: promotion?.minOrderAmount?.toString() ?? '',
    );
    _maxDiscountAmountController = TextEditingController(
      text: promotion?.maxDiscountAmount?.toString() ?? '',
    );

    _discountType = promotion?.discountType ?? PromotionDiscountType.percent;
    _targetType = promotion?.targetType ?? PromotionTargetType.allProducts;
    _selectedTargetId = promotion?.targetId;
    _selectedTargetName = promotion?.targetName;

    _branchScope = promotion?.branchScope ?? PromotionBranchScope.allBranches;
    _active = promotion?.active ?? true;

    _startDate = promotion?.startDate;
    _endDate = promotion?.endDate;

    _selectedBranchIds.addAll(promotion?.selectedBranchIds ?? []);
    _selectedBranchNames.addAll(promotion?.selectedBranchNames ?? []);

    if (!_isPercent) {
      _maxDiscountAmountController.clear();
    }

    _validateDates();
    _loadLookups();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minOrderAmountController.dispose();
    _maxDiscountAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      _loadTargets(),
      _loadBranches(),
    ]);
  }

  Future<void> _loadTargets() async {
    setState(() {
      _loadingTargets = true;
      _targetErrorMessage = null;
    });

    try {
      final results = await Future.wait([
        _lookupService.getProducts(),
        _lookupService.getCategories(),
        _lookupService.getSubCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        _products
          ..clear()
          ..addAll(results[0]);

        _categories
          ..clear()
          ..addAll(results[1]);

        _subCategories
          ..clear()
          ..addAll(results[2]);

        _syncEditSubCategoryParent();
        _loadingTargets = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _targetErrorMessage = e.toString();
        _loadingTargets = false;
      });
    }
  }

  Future<void> _loadBranches() async {
    setState(() {
      _loadingBranches = true;
      _branchErrorMessage = null;
    });

    try {
      final branches = await _lookupService.getBranches();

      if (!mounted) return;

      setState(() {
        _branches
          ..clear()
          ..addAll(branches);
        _loadingBranches = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _branchErrorMessage = e.toString();
        _loadingBranches = false;
      });
    }
  }

  void _syncEditSubCategoryParent() {
    if (_targetType != PromotionTargetType.subcategory ||
        _selectedTargetId == null) {
      return;
    }

    final selectedSubCategory = _subCategories.where(
      (item) => item.id == _selectedTargetId,
    );

    if (selectedSubCategory.isNotEmpty) {
      _selectedTargetCategoryId = selectedSubCategory.first.categoryId;
    }
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _requiredPositiveNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  String? _optionalNonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  String? _discountValueValidator(String? value) {
    final baseError = _requiredPositiveNumber(value, 'Discount Value');
    if (baseError != null) return baseError;

    final parsed = double.tryParse(value!.trim()) ?? 0;

    if (_discountType == PromotionDiscountType.percent && parsed > 100) {
      return 'Percent discount cannot be greater than 100';
    }

    return null;
  }

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  void _handleDiscountTypeChanged(PromotionDiscountType? value) {
    if (value == null) return;

    setState(() {
      _discountType = value;

      if (!_isPercent) {
        _maxDiscountAmountController.clear();
      }
    });
  }

  void _handleTargetTypeChanged(PromotionTargetType? value) {
    if (value == null) return;

    setState(() {
      _targetType = value;
      _selectedTargetId = null;
      _selectedTargetName = null;
      _selectedTargetCategoryId = null;
    });
  }

  void _handleTargetSelected(_PromotionLookupOption? option) {
    setState(() {
      _selectedTargetId = option?.id;
      _selectedTargetName = option?.label;
    });
  }

  void _handleSubCategoryParentSelected(String? categoryId) {
    setState(() {
      _selectedTargetCategoryId = categoryId;
      _selectedTargetId = null;
      _selectedTargetName = null;
    });
  }

  void _toggleBranch(_PromotionLookupOption branch, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedBranchIds.contains(branch.id)) {
          _selectedBranchIds.add(branch.id);
          _selectedBranchNames.add(branch.label);
        }
      } else {
        _selectedBranchIds.remove(branch.id);
        _selectedBranchNames.remove(branch.label);
      }
    });
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '—';

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null || !mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void _validateDates() {
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      _dateError = 'End date must be after start date';
    } else {
      _dateError = null;
    }
  }

  List<_PromotionLookupOption> get _filteredSubCategories {
    if (_selectedTargetCategoryId == null) return [];

    return _subCategories
        .where((item) => item.categoryId == _selectedTargetCategoryId)
        .toList();
  }

  bool _validateTargetSelection(BuildContext context) {
    if (_targetType == PromotionTargetType.allProducts) return true;

    if (_targetType == PromotionTargetType.subcategory &&
        _selectedTargetCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first')),
      );
      return false;
    }

    if (_selectedTargetId == null || _selectedTargetId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select ${_targetType.label}')),
      );
      return false;
    }

    return true;
  }

  void _savePromotion(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    _validateDates();
    if (_dateError != null) {
      setState(() {});
      return;
    }

    if (!_validateTargetSelection(context)) return;

    if (_branchScope == PromotionBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one branch'),
        ),
      );
      return;
    }

    final now = DateTime.now();

    final promotion = PromotionEntity(
      id: widget.promotion?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text.trim()),
      targetType: _targetType,
      targetId: _targetType == PromotionTargetType.allProducts
          ? null
          : _selectedTargetId,
      targetName: _targetType == PromotionTargetType.allProducts
          ? 'All Products'
          : _selectedTargetName,
      minOrderAmount: _parseOptionalDouble(_minOrderAmountController.text),
      maxDiscountAmount: _isPercent
          ? _parseOptionalDouble(_maxDiscountAmountController.text)
          : null,
      startDate: _startDate,
      endDate: _endDate,
      active: _active,
      status: widget.promotion?.status,
      currentlyValid: widget.promotion?.currentlyValid ?? false,
      branchScope: _branchScope,
      selectedBranchIds: _branchScope == PromotionBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchIds),
      selectedBranchNames: _branchScope == PromotionBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchNames),
      createdAt: widget.promotion?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<PromotionsBloc>().add(
            UpdatePromotionRequested(promotion),
          );
    } else {
      context.read<PromotionsBloc>().add(
            CreatePromotionRequested(promotion),
          );
    }
  }

  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-promotions');
    } else {
      context.go('/supplier-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<PromotionsBloc, PromotionsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );

          context.read<PromotionsBloc>().add(
                const ClearPromotionMessageRequested(),
              );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

          context.read<PromotionsBloc>().add(
                const ClearPromotionMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-promotions');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<PromotionsBloc, PromotionsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              backgroundColor: AppThemeTokens.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: state.saving ? null : _cancel,
                icon: const Icon(Icons.arrow_back, size: 28),
              ),
              title: Text(
                _isEditMode ? 'Edit Promotion' : 'Create Promotion',
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(
                  color: AppThemeTokens.surface,
                  border: Border(top: BorderSide(color: AppThemeTokens.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: state.saving ? null : _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppThemeTokens.textPrimary,
                            backgroundColor: AppThemeTokens.surface,
                            side: const BorderSide(
                              color: AppThemeTokens.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state.saving
                              ? null
                              : () => _savePromotion(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: state.saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEditMode
                                      ? 'Update Promotion'
                                      : 'Create Promotion',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Promotion Information',
                        children: [
                          _FieldLabel('Promotion Title *'),
                          _InputField(
                            controller: _titleController,
                            hintText: 'Food category wholesale deal',
                            validator: (value) {
                              return _required(value, 'Promotion Title');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Description'),
                          _InputField(
                            controller: _descriptionController,
                            hintText:
                                'Short description shown later to retailer side',
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Discount',
                        children: [
                          _FieldLabel('Discount Type *'),
                          _DiscountTypeDropdown(
                            value: _discountType,
                            onChanged: _handleDiscountTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: _isPercent
                                ? 'Percent discount means percentage off, for example 10% off. Maximum discount amount can limit supplier loss.'
                                : 'Fixed discount means a fixed amount off, for example \$20 off.',
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Discount Value *'),
                          _InputField(
                            controller: _discountValueController,
                            hintText: _isPercent ? '10' : '20',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _discountValueValidator,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Promotion Target',
                        children: [
                          _FieldLabel('Applies To *'),
                          _TargetTypeDropdown(
                            value: _targetType,
                            onChanged: _handleTargetTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'The target defines which products are included in the promotion. Branch availability is selected separately below.',
                          ),
                          if (_targetType != PromotionTargetType.allProducts)
                            ...[
                              const _DividerSpace(),
                              if (_loadingTargets)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_targetErrorMessage != null)
                                _ErrorText(message: _targetErrorMessage!)
                              else
                                _TargetSelectionSection(
                                  targetType: _targetType,
                                  products: _products,
                                  categories: _categories,
                                  subCategories: _subCategories,
                                  selectedTargetId: _selectedTargetId,
                                  selectedCategoryId: _selectedTargetCategoryId,
                                  filteredSubCategories: _filteredSubCategories,
                                  onRefresh: _loadTargets,
                                  onTargetSelected: _handleTargetSelected,
                                  onCategoryForSubCategorySelected:
                                      _handleSubCategoryParentSelected,
                                ),
                            ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Promotion Rules',
                        children: [
                          _FieldLabel('Minimum Order Amount'),
                          _InputField(
                            controller: _minOrderAmountController,
                            hintText: '100',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalNonNegativeNumber(
                                value,
                                'Minimum Order Amount',
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Maximum Discount Amount'),
                          _InputField(
                            controller: _maxDiscountAmountController,
                            hintText:
                                _isPercent ? '50' : 'Only for percent discounts',
                            enabled: _isPercent,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalNonNegativeNumber(
                                value,
                                'Maximum Discount Amount',
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: _isPercent
                                ? 'Optional. It limits the total discount when using percent promotions.'
                                : 'Maximum discount amount is not needed for fixed promotions.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Branch Applicability',
                        children: [
                          _FieldLabel('Applies To *'),
                          _BranchScopeDropdown(
                            value: _branchScope,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _branchScope = value;

                                if (_branchScope ==
                                    PromotionBranchScope.allBranches) {
                                  _selectedBranchIds.clear();
                                  _selectedBranchNames.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Branches define where the promotion is valid. Product/category selection above is not filtered by branch.',
                          ),
                          if (_branchScope ==
                              PromotionBranchScope.selectedBranches) ...[
                            const _DividerSpace(),
                            Row(
                              children: [
                                const Expanded(
                                  child: _FieldLabel('Select Branches'),
                                ),
                                TextButton(
                                  onPressed: _loadingBranches
                                      ? null
                                      : _loadBranches,
                                  child: const Text(
                                    'Refresh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_loadingBranches)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_branchErrorMessage != null)
                              _ErrorText(message: _branchErrorMessage!)
                            else if (_branches.isEmpty)
                              const Text(
                                'No active branches available. Add branches from Branch Management first.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeTokens.textSecondary,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _branches.map((branch) {
                                  final selected =
                                      _selectedBranchIds.contains(branch.id);

                                  return FilterChip(
                                    selected: selected,
                                    label: Text(branch.label),
                                    selectedColor:
                                        primary.withValues(alpha: 0.15),
                                    checkmarkColor: primary,
                                    onSelected: (isSelected) {
                                      _toggleBranch(branch, isSelected);
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Schedule & Status',
                        children: [
                          _DateTimePickerRow(
                            label: 'Start Date',
                            value: _formatDateTime(_startDate),
                            onPick: () async {
                              final picked = await _pickDateTime(_startDate);

                              if (picked == null) return;

                              setState(() {
                                _startDate = picked;
                                _validateDates();
                              });
                            },
                            onClear: () {
                              setState(() {
                                _startDate = null;
                                _validateDates();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _DateTimePickerRow(
                            label: 'End Date',
                            value: _formatDateTime(_endDate),
                            onPick: () async {
                              final picked = await _pickDateTime(_endDate);

                              if (picked == null) return;

                              setState(() {
                                _endDate = picked;
                                _validateDates();
                              });
                            },
                            onClear: () {
                              setState(() {
                                _endDate = null;
                                _validateDates();
                              });
                            },
                          ),
                          if (_dateError != null) ...[
                            const SizedBox(height: 10),
                            _ErrorText(message: _dateError!),
                          ],
                          const _DividerSpace(),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _active,
                                activeThumbColor: Colors.white,
                                activeTrackColor: primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFD1D5DB),
                                onChanged: (value) {
                                  setState(() {
                                    _active = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TargetSelectionSection extends StatelessWidget {
  final PromotionTargetType targetType;
  final List<_PromotionLookupOption> products;
  final List<_PromotionLookupOption> categories;
  final List<_PromotionLookupOption> subCategories;
  final List<_PromotionLookupOption> filteredSubCategories;
  final String? selectedTargetId;
  final String? selectedCategoryId;
  final VoidCallback onRefresh;
  final ValueChanged<_PromotionLookupOption?> onTargetSelected;
  final ValueChanged<String?> onCategoryForSubCategorySelected;

  const _TargetSelectionSection({
    required this.targetType,
    required this.products,
    required this.categories,
    required this.subCategories,
    required this.filteredSubCategories,
    required this.selectedTargetId,
    required this.selectedCategoryId,
    required this.onRefresh,
    required this.onTargetSelected,
    required this.onCategoryForSubCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (targetType == PromotionTargetType.product) {
      return _LookupDropdownBlock(
        label: 'Select Product *',
        emptyText: 'No active products available.',
        options: products,
        selectedId: selectedTargetId,
        onRefresh: onRefresh,
        onChanged: onTargetSelected,
      );
    }

    if (targetType == PromotionTargetType.category) {
      return _LookupDropdownBlock(
        label: 'Select Category *',
        emptyText: 'No active categories available.',
        options: categories,
        selectedId: selectedTargetId,
        onRefresh: onRefresh,
        onChanged: onTargetSelected,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Select Category *'),
        _SimpleStringDropdown(
          value: _safeSelectedId(selectedCategoryId, categories),
          hintText: 'Choose category',
          items: categories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.label),
                ),
              )
              .toList(),
          onChanged: onCategoryForSubCategorySelected,
        ),
        const SizedBox(height: 12),
        _LookupDropdownBlock(
          label: 'Select SubCategory *',
          emptyText: selectedCategoryId == null
              ? 'Select a category first.'
              : 'No active subcategories for this category.',
          options: filteredSubCategories,
          selectedId: selectedTargetId,
          onRefresh: onRefresh,
          onChanged: onTargetSelected,
        ),
      ],
    );
  }

  static String? _safeSelectedId(
    String? selectedId,
    List<_PromotionLookupOption> options,
  ) {
    if (selectedId == null) return null;

    return options.any((item) => item.id == selectedId) ? selectedId : null;
  }
}

class _LookupDropdownBlock extends StatelessWidget {
  final String label;
  final String emptyText;
  final List<_PromotionLookupOption> options;
  final String? selectedId;
  final VoidCallback onRefresh;
  final ValueChanged<_PromotionLookupOption?> onChanged;

  const _LookupDropdownBlock({
    required this.label,
    required this.emptyText,
    required this.options,
    required this.selectedId,
    required this.onRefresh,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeSelectedId =
        options.any((item) => item.id == selectedId) ? selectedId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _FieldLabel(label)),
            TextButton(
              onPressed: onRefresh,
              child: const Text(
                'Refresh',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        if (options.isEmpty)
          Text(
            emptyText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: safeSelectedId,
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final selected = options.where((item) => item.id == value);

              onChanged(selected.isEmpty ? null : selected.first);
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return label.replaceAll('*', '').trim() + ' is required';
              }

              return null;
            },
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textPrimary,
            ),
            decoration: _dropdownDecoration(context),
          ),
      ],
    );
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppThemeTokens.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: enabled ? AppThemeTokens.surface : const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: _border(),
        enabledBorder: _border(),
        disabledBorder: _border(color: const Color(0xFFE5E7EB)),
        focusedBorder: _border(
          color: Theme.of(context).colorScheme.primary,
        ),
        errorBorder: _border(color: Colors.red),
        focusedErrorBorder: _border(color: Colors.red),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _DiscountTypeDropdown extends StatelessWidget {
  final PromotionDiscountType value;
  final ValueChanged<PromotionDiscountType?> onChanged;

  const _DiscountTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PromotionDiscountType>(
      initialValue: value,
      items: PromotionDiscountType.values
          .map(
            (type) => DropdownMenuItem<PromotionDiscountType>(
              value: type,
              child: Text(type.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _TargetTypeDropdown extends StatelessWidget {
  final PromotionTargetType value;
  final ValueChanged<PromotionTargetType?> onChanged;

  const _TargetTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PromotionTargetType>(
      initialValue: value,
      items: PromotionTargetType.values
          .map(
            (type) => DropdownMenuItem<PromotionTargetType>(
              value: type,
              child: Text(type.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _BranchScopeDropdown extends StatelessWidget {
  final PromotionBranchScope value;
  final ValueChanged<PromotionBranchScope?> onChanged;

  const _BranchScopeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PromotionBranchScope>(
      initialValue: value,
      items: PromotionBranchScope.values
          .map(
            (scope) => DropdownMenuItem<PromotionBranchScope>(
              value: scope,
              child: Text(scope.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _SimpleStringDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _SimpleStringDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: (selectedValue) {
        if (selectedValue == null || selectedValue.trim().isEmpty) {
          return hintText;
        }

        return null;
      },
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context),
    );
  }
}

class _DateTimePickerRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DateTimePickerRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeTokens.border),
        color: AppThemeTokens.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeTokens.textPrimary,
                      side: const BorderSide(color: AppThemeTokens.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Pick',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  final String text;

  const _HelpText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppThemeTokens.textSecondary,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.red,
      ),
    );
  }
}

class _DividerSpace extends StatelessWidget {
  const _DividerSpace();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: AppThemeTokens.border),
    );
  }
}

InputDecoration _dropdownDecoration(BuildContext context) {
  OutlineInputBorder border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  return InputDecoration(
    filled: true,
    fillColor: AppThemeTokens.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),
    border: border(),
    enabledBorder: border(),
    focusedBorder: border(
      color: Theme.of(context).colorScheme.primary,
    ),
    errorBorder: border(color: Colors.red),
    focusedErrorBorder: border(color: Colors.red),
  );
}

class _PromotionLookupOption {
  final String id;
  final String label;
  final String? categoryId;
  final String? categoryName;

  const _PromotionLookupOption({
    required this.id,
    required this.label,
    this.categoryId,
    this.categoryName,
  });

  factory _PromotionLookupOption.fromJson(
    Map<String, dynamic> json, {
    required String fallbackPrefix,
  }) {
    final id = _firstNonEmpty(json, [
      'id',
      'productId',
      'categoryId',
      'subCategoryId',
      'subcategoryId',
    ]);

    final name = _firstNonEmpty(json, [
      'name',
      'productName',
      'categoryName',
      'subCategoryName',
      'subcategoryName',
      'title',
    ]);

    final categoryId = _firstNonEmpty(json, [
      'categoryId',
      'parentCategoryId',
    ]);

    final categoryName = _firstNonEmpty(json, [
      'categoryName',
      'parentCategoryName',
    ]);

    return _PromotionLookupOption(
      id: id,
      label: name.isEmpty ? '$fallbackPrefix #$id' : name,
      categoryId: categoryId.isEmpty ? null : categoryId,
      categoryName: categoryName.isEmpty ? null : categoryName,
    );
  }

  static String _firstNonEmpty(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}

class _PromotionLookupService {
  final ApiClient apiClient;

  _PromotionLookupService(this.apiClient);

  Future<List<_PromotionLookupOption>> getProducts() async {
    final response = await apiClient.dio.get(ApiConfig.supplierProducts);

    return _parseList(
      response.data,
      fallbackPrefix: 'Product',
    );
  }

  Future<List<_PromotionLookupOption>> getCategories() async {
    final response = await apiClient.dio.get(ApiConfig.supplierCategories);

    return _parseList(
      response.data,
      fallbackPrefix: 'Category',
    );
  }

  Future<List<_PromotionLookupOption>> getSubCategories() async {
    final response = await apiClient.dio.get(ApiConfig.supplierSubCategories);

    return _parseList(
      response.data,
      fallbackPrefix: 'SubCategory',
    );
  }

  Future<List<_PromotionLookupOption>> getBranches() async {
    final response = await apiClient.dio.get(ApiConfig.supplierBranches);

    final rawOptions = _parseList(
      response.data,
      fallbackPrefix: 'Branch',
    );

    if (response.data is List) {
      final filtered = <_PromotionLookupOption>[];

      for (final item in response.data as List) {
        if (item is! Map) continue;

        final json = Map<String, dynamic>.from(item);
        final status = json['status']?.toString().toUpperCase();

        if (status == null || status == 'ACTIVE') {
          filtered.add(
            _PromotionLookupOption.fromJson(
              json,
              fallbackPrefix: 'Branch',
            ),
          );
        }
      }

      return filtered;
    }

    return rawOptions;
  }

  List<_PromotionLookupOption> _parseList(
    dynamic data, {
    required String fallbackPrefix,
  }) {
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => _PromotionLookupOption.fromJson(
            Map<String, dynamic>.from(item),
            fallbackPrefix: fallbackPrefix,
          ),
        )
        .where((item) => item.id.trim().isNotEmpty)
        .toList();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
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
  PromotionTargetType _targetType = PromotionTargetType.product;

  String? _selectedTargetId;
  String? _selectedTargetName;
  _PromotionEligibleTarget? _selectedTargetAvailability;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  bool _active = true;
  bool _loadingTargets = true;
  String? _targetErrorMessage;

  final List<_PromotionEligibleTarget> _eligibleProducts = [];
  final List<_PromotionEligibleTarget> _eligibleCategories = [];

  bool get _isEditMode => widget.promotion != null;

  bool get _isPercent => _discountType == PromotionDiscountType.percent;

  List<_PromotionEligibleTarget> get _currentOptions {
    return _targetType == PromotionTargetType.product
        ? _eligibleProducts
        : _eligibleCategories;
  }

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
    _targetType = _normalizeEditableTargetType(promotion?.targetType);
    _selectedTargetId = promotion?.targetId;
    _selectedTargetName = promotion?.targetName;
    _active = promotion?.active ?? true;
    _startDate = promotion?.startDate;
    _endDate = promotion?.endDate;

    if (!_isPercent) {
      _maxDiscountAmountController.clear();
    }

    _validateDates();
    _loadTargets();
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

  PromotionTargetType _normalizeEditableTargetType(PromotionTargetType? value) {
    if (value == PromotionTargetType.category) {
      return PromotionTargetType.category;
    }

    return PromotionTargetType.product;
  }

  Future<void> _loadTargets() async {
    setState(() {
      _loadingTargets = true;
      _targetErrorMessage = null;
    });

    try {
      final results = await Future.wait([
        _lookupService.getEligibleProducts(),
        _lookupService.getEligibleCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        _eligibleProducts
          ..clear()
          ..addAll(results[0]);
        _eligibleCategories
          ..clear()
          ..addAll(results[1]);

        _syncSelectedTargetAfterReload();
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

  void _syncSelectedTargetAfterReload() {
    if (_selectedTargetId == null) return;

    final matched = _currentOptions.where((item) => item.id == _selectedTargetId);
    if (matched.isNotEmpty) {
      _selectedTargetAvailability = matched.first;
      _selectedTargetName = matched.first.name;
    }
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.supplierFieldRequired(fieldName);
    }

    return null;
  }

  String? _requiredPositiveNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed <= 0) {
      return context.l10n.supplierFieldGreaterThanZero(fieldName);
    }

    return null;
  }

  String? _optionalNonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return context.l10n.supplierFieldValidNumber(fieldName);
    }

    return null;
  }

  String? _discountValueValidator(String? value) {
    final baseError = _requiredPositiveNumber(
      value,
      context.l10n.supplierDiscountValuePlain,
    );
    if (baseError != null) return baseError;

    final parsed = double.tryParse(value!.trim()) ?? 0;

    if (_discountType == PromotionDiscountType.percent && parsed > 100) {
      return context.l10n.supplierPercentDiscountCannotBeGreaterThan100;
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
      _selectedTargetAvailability = null;
    });
  }

  void _handleTargetSelected(_PromotionEligibleTarget option) {
    setState(() {
      _selectedTargetId = option.id;
      _selectedTargetName = option.name;
      _selectedTargetAvailability = option;
    });
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '—';

    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return DateFormat('yyyy-MM-dd h:mm a', localeTag).format(date);
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      locale: Localizations.localeOf(context),
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

  void _validateDates({bool requireBothDates = false}) {
    if (requireBothDates && _startDate == null) {
      _dateError = context.l10n.supplierFieldRequired(
        context.l10n.supplierStartDate,
      );
      return;
    }

    if (requireBothDates && _endDate == null) {
      _dateError = context.l10n.supplierFieldRequired(
        context.l10n.supplierEndDate,
      );
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      _dateError = context.l10n.supplierEndDateAfterStartDate;
      return;
    }

    _dateError = null;
  }

  bool _validateTargetSelection(BuildContext context) {
    if (_selectedTargetId == null || _selectedTargetId!.trim().isEmpty) {
      final targetName = _targetType == PromotionTargetType.product
          ? context.l10n.productLabel
          : context.l10n.categoryLabel;

      AppToast.error(context, context.l10n.supplierPleaseSelectTarget(targetName));
      return false;
    }

    if (_selectedTargetAvailability == null ||
        _selectedTargetAvailability!.totalStock <= 0 ||
        _selectedTargetAvailability!.branches.isEmpty) {
      AppToast.error(
        context,
        'This target has no in-stock items in active branches. Please refresh and choose another target.',
      );
      return false;
    }

    return true;
  }

  void _savePromotion(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    _validateDates(requireBothDates: true);
    if (_dateError != null) {
      setState(() {});
      return;
    }

    if (!_validateTargetSelection(context)) return;

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
      targetId: _selectedTargetId,
      targetName: _selectedTargetName,
      minOrderAmount: _parseOptionalDouble(_minOrderAmountController.text),
      maxDiscountAmount: _isPercent
          ? _parseOptionalDouble(_maxDiscountAmountController.text)
          : null,
      startDate: _startDate,
      endDate: _endDate,
      active: _active,
      status: widget.promotion?.status,
      currentlyValid: widget.promotion?.currentlyValid ?? false,
      branchScope: PromotionBranchScope.allBranches,
      selectedBranchIds: const [],
      selectedBranchNames: const [],
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
          AppToast.error(context, state.errorMessage!);

          context.read<PromotionsBloc>().add(
                const ClearPromotionMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(context, state.successMessage!);

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
                _isEditMode
                    ? context.l10n.supplierEditPromotion
                    : context.l10n.supplierCreatePromotion,
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
                          child: Text(
                            context.l10n.cancelButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              state.saving ? null : () => _savePromotion(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: state.saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEditMode
                                      ? context.l10n.updateButton
                                      : context.l10n.addButton,
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
                        title: context.l10n.supplierPromotionInformation,
                        children: [
                          _FieldLabel(context.l10n.supplierPromotionTitle),
                          _InputField(
                            controller: _titleController,
                            hintText: context.l10n.supplierPromotionTitleHint,
                            validator: (value) {
                              return _required(
                                value,
                                context.l10n.supplierPromotionTitlePlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.descriptionLabel),
                          _InputField(
                            controller: _descriptionController,
                            hintText:
                                context.l10n.supplierPromotionDescriptionHint,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierDiscount,
                        children: [
                          _FieldLabel(context.l10n.supplierDiscountType),
                          _DiscountTypeDropdown(
                            value: _discountType,
                            onChanged: _handleDiscountTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: _isPercent
                                ? context.l10n.supplierPercentDiscountHelp
                                : context.l10n.supplierFixedDiscountHelp,
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierDiscountValue),
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
                        title: context.l10n.supplierPromotionTarget,
                        children: [
                          _FieldLabel(context.l10n.supplierAppliesTo),
                          _TargetTypeDropdown(
                            value: _targetType,
                            onChanged: _handleTargetTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          const _HelpText(
                            text:
                                'Promotions can target only an in-stock product or an in-stock category. Branches are detected automatically from inventory.',
                          ),
                          const _DividerSpace(),
                          if (_loadingTargets)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_targetErrorMessage != null)
                            _ErrorText(message: _targetErrorMessage!)
                          else
                            _TargetSelectionSection(
                              targetType: _targetType,
                              options: _currentOptions,
                              selectedTarget: _selectedTargetAvailability,
                              selectedFallbackName: _selectedTargetName,
                              onRefresh: _loadTargets,
                              onTargetSelected: _handleTargetSelected,
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Automatic stock detection',
                        children: [
                          if (_selectedTargetAvailability == null)
                            const _HelpText(
                              text:
                                  'Choose a product or category to see where it has available stock. You do not select branches manually anymore.',
                            )
                          else
                            _AvailabilityDetails(
                              target: _selectedTargetAvailability!,
                              targetType: _targetType,
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierPromotionRules,
                        children: [
                          _FieldLabel(context.l10n.supplierMinimumOrderAmount),
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
                                context.l10n.supplierMinimumOrderAmountPlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(
                            context.l10n.supplierMaximumDiscountAmount,
                          ),
                          _InputField(
                            controller: _maxDiscountAmountController,
                            hintText: _isPercent
                                ? '50'
                                : context.l10n.supplierOnlyForPercentDiscounts,
                            enabled: _isPercent,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalNonNegativeNumber(
                                value,
                                context.l10n.supplierMaximumDiscountAmountPlain,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _HelpText(
                            text: _isPercent
                                ? context.l10n.supplierMaxDiscountPercentHelp
                                : context.l10n.supplierMaxDiscountFixedHelp,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierScheduleStatus,
                        children: [
                          _DateTimePickerRow(
                            label: context.l10n.supplierStartDate,
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
                            label: context.l10n.supplierEndDate,
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
                              Expanded(
                                child: Text(
                                  context.l10n.activeStatus,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _active,
                                thumbColor: WidgetStateProperty.all(Colors.white),
                                activeTrackColor: primary,
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
  final List<_PromotionEligibleTarget> options;
  final _PromotionEligibleTarget? selectedTarget;
  final String? selectedFallbackName;
  final VoidCallback onRefresh;
  final ValueChanged<_PromotionEligibleTarget> onTargetSelected;

  const _TargetSelectionSection({
    required this.targetType,
    required this.options,
    required this.selectedTarget,
    required this.selectedFallbackName,
    required this.onRefresh,
    required this.onTargetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isProduct = targetType == PromotionTargetType.product;
    final label = isProduct
        ? context.l10n.supplierSelectProduct
        : context.l10n.supplierSelectCategory;
    final emptyText = isProduct
        ? 'No in-stock products are available for promotion.'
        : 'No in-stock categories are available for promotion.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _FieldLabel(label)),
            TextButton(
              onPressed: onRefresh,
              child: Text(
                context.l10n.refreshButton,
                style: const TextStyle(fontWeight: FontWeight.w900),
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
          _SearchableTargetField(
            hintText: isProduct
                ? 'Search and choose an in-stock product'
                : 'Search and choose an in-stock category',
            selectedText: selectedTarget?.name ?? selectedFallbackName,
            options: options,
            targetType: targetType,
            onSelected: onTargetSelected,
          ),
      ],
    );
  }
}

class _SearchableTargetField extends StatelessWidget {
  final String hintText;
  final String? selectedText;
  final List<_PromotionEligibleTarget> options;
  final PromotionTargetType targetType;
  final ValueChanged<_PromotionEligibleTarget> onSelected;

  const _SearchableTargetField({
    required this.hintText,
    required this.selectedText,
    required this.options,
    required this.targetType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final selected = await showModalBottomSheet<_PromotionEligibleTarget>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: AppThemeTokens.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _TargetSearchSheet(
            title: targetType == PromotionTargetType.product
                ? 'Choose product'
                : 'Choose category',
            options: options,
            targetType: targetType,
          ),
        );

        if (selected != null) {
          onSelected(selected);
        }
      },
      child: InputDecorator(
        decoration: _dropdownDecoration(context),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedText == null || selectedText!.trim().isEmpty
                    ? hintText
                    : selectedText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selectedText == null || selectedText!.trim().isEmpty
                      ? AppThemeTokens.textSecondary
                      : AppThemeTokens.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.search, color: AppThemeTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TargetSearchSheet extends StatefulWidget {
  final String title;
  final List<_PromotionEligibleTarget> options;
  final PromotionTargetType targetType;

  const _TargetSearchSheet({
    required this.title,
    required this.options,
    required this.targetType,
  });

  @override
  State<_TargetSearchSheet> createState() => _TargetSearchSheetState();
}

class _TargetSearchSheetState extends State<_TargetSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_PromotionEligibleTarget> get _filteredOptions {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return widget.options;

    return widget.options.where((option) {
      return option.name.toLowerCase().contains(normalized);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppThemeTokens.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppThemeTokens.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppThemeTokens.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredOptions.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching result',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        return _TargetOptionTile(
                          option: option,
                          targetType: widget.targetType,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _filteredOptions.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetOptionTile extends StatelessWidget {
  final _PromotionEligibleTarget option;
  final PromotionTargetType targetType;
  final VoidCallback onTap;

  const _TargetOptionTile({
    required this.option,
    required this.targetType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProduct = targetType == PromotionTargetType.product;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeTokens.border),
          color: AppThemeTokens.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isProduct ? Icons.inventory_2_outlined : Icons.category_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isProduct
                        ? 'Available in ${option.branches.length} branches • Total stock: ${option.totalStock}'
                        : '${option.eligibleProductsCount} eligible products • ${option.branches.length} branches • Total stock: ${option.totalStock}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppThemeTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityDetails extends StatelessWidget {
  final _PromotionEligibleTarget target;
  final PromotionTargetType targetType;

  const _AvailabilityDetails({
    required this.target,
    required this.targetType,
  });

  @override
  Widget build(BuildContext context) {
    final isProduct = targetType == PromotionTargetType.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            isProduct
                ? 'This product can be promoted because it has stock in ${target.branches.length} active branch(es).'
                : 'This category can be promoted because it has ${target.eligibleProductsCount} in-stock product(s) across ${target.branches.length} active branch(es).',
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _FieldLabel('Detected branches'),
        const SizedBox(height: 8),
        ...target.branches.map(
          (branch) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DetectedBranchRow(branch: branch),
          ),
        ),
      ],
    );
  }
}

class _DetectedBranchRow extends StatelessWidget {
  final _PromotionEligibilityBranch branch;

  const _DetectedBranchRow({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeTokens.border),
        color: AppThemeTokens.background,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.store_mall_directory_outlined,
            color: AppThemeTokens.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                if (branch.city != null && branch.city!.trim().isNotEmpty)
                  Text(
                    branch.city!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.green.withValues(alpha: 0.12),
            ),
            child: Text(
              'Stock ${branch.stockQuantity}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
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
      borderRadius: BorderRadius.circular(14),
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
      value: value,
      items: PromotionDiscountType.values
          .map(
            (type) => DropdownMenuItem<PromotionDiscountType>(
              value: type,
              child: Text(_localizedEnumLabel(context, type.label)),
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
    const allowedTargetTypes = [
      PromotionTargetType.product,
      PromotionTargetType.category,
    ];

    return DropdownButtonFormField<PromotionTargetType>(
      value: value,
      items: allowedTargetTypes
          .map(
            (type) => DropdownMenuItem<PromotionTargetType>(
              value: type,
              child: Text(_localizedEnumLabel(context, type.label)),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPick,
            icon: Icon(Icons.calendar_month_outlined, color: primary),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear, color: AppThemeTokens.textSecondary),
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
        fontSize: 12.5,
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
        color: Colors.red,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DividerSpace extends StatelessWidget {
  const _DividerSpace();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16);
  }
}

class _PromotionEligibilityBranch {
  final String id;
  final String name;
  final String? city;
  final int stockQuantity;

  const _PromotionEligibilityBranch({
    required this.id,
    required this.name,
    this.city,
    required this.stockQuantity,
  });

  factory _PromotionEligibilityBranch.fromJson(Map<String, dynamic> json) {
    return _PromotionEligibilityBranch(
      id: json['id']?.toString() ?? '',
      name: _cleanText(json['name']) ?? 'Branch',
      city: _cleanText(json['city']),
      stockQuantity: _intFromJson(json['stockQuantity']),
    );
  }
}

class _PromotionEligibleTarget {
  final String id;
  final String name;
  final PromotionTargetType targetType;
  final int totalStock;
  final int eligibleProductsCount;
  final List<_PromotionEligibilityBranch> branches;

  const _PromotionEligibleTarget({
    required this.id,
    required this.name,
    required this.targetType,
    required this.totalStock,
    required this.eligibleProductsCount,
    required this.branches,
  });

  factory _PromotionEligibleTarget.fromJson(Map<String, dynamic> json) {
    final targetType = PromotionTargetTypeX.fromBackendValue(
      json['targetType'],
    );

    final branches = <_PromotionEligibilityBranch>[];
    final rawBranches = json['branches'];
    if (rawBranches is List) {
      for (final item in rawBranches) {
        if (item is Map) {
          final branch = _PromotionEligibilityBranch.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (branch.id.trim().isNotEmpty) {
            branches.add(branch);
          }
        }
      }
    }

    return _PromotionEligibleTarget(
      id: json['id']?.toString() ?? '',
      name: _cleanText(json['name']) ?? 'Target',
      targetType: targetType,
      totalStock: _intFromJson(json['totalStock']),
      eligibleProductsCount: _intFromJson(json['eligibleProductsCount']),
      branches: branches,
    );
  }
}

class _PromotionLookupService {
  final ApiClient apiClient;

  _PromotionLookupService(this.apiClient);

  Future<List<_PromotionEligibleTarget>> getEligibleProducts() async {
    final response = await apiClient.dio.get(
      ApiConfig.supplierPromotionEligibleProducts,
    );

    return _parseEligibleTargets(response.data);
  }

  Future<List<_PromotionEligibleTarget>> getEligibleCategories() async {
    final response = await apiClient.dio.get(
      ApiConfig.supplierPromotionEligibleCategories,
    );

    return _parseEligibleTargets(response.data);
  }

  List<_PromotionEligibleTarget> _parseEligibleTargets(dynamic data) {
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map(
          (item) => _PromotionEligibleTarget.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) =>
            item.id.trim().isNotEmpty &&
            item.totalStock > 0 &&
            item.branches.isNotEmpty)
        .toList();
  }
}

InputDecoration _dropdownDecoration(BuildContext context) {
  OutlineInputBorder border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
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

String? _cleanText(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _localizedEnumLabel(BuildContext context, String label) {
  switch (label) {
    case 'Percent':
      return context.l10n.supplierPercent;
    case 'Fixed Amount':
      return context.l10n.supplierFixedAmount;
    case 'Product':
      return context.l10n.productLabel;
    case 'Category':
      return context.l10n.categoryLabel;
    default:
      return label;
  }
}

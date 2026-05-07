import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../branches/data/services/branch_api_service.dart';
import '../../../branches/domain/entities/branch_entity.dart';
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

  final BranchApiService _branchApiService = sl<BranchApiService>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _minOrderAmountController;
  late final TextEditingController _maxDiscountAmountController;

  PromotionDiscountType _discountType = PromotionDiscountType.percent;
  PromotionBranchScope _branchScope = PromotionBranchScope.allBranches;

  bool _active = true;
  bool _loadingBranches = true;

  String? _dateError;
  String? _branchErrorMessage;

  DateTime? _startsAt;
  DateTime? _expiresAt;

  final List<BranchEntity> _availableBranches = [];
  final List<String> _selectedBranchIds = [];
  final List<String> _selectedBranchNames = [];

  bool get _isEditMode => widget.promotion != null;
  bool get _isPercent => _discountType == PromotionDiscountType.percent;
  bool get _isFreeShipping =>
      _discountType == PromotionDiscountType.freeShipping;

  @override
  void initState() {
    super.initState();

    final promotion = widget.promotion;

    _titleController = TextEditingController(text: promotion?.title ?? '');
    _descriptionController = TextEditingController(
      text: promotion?.description ?? '',
    );

    _discountValueController = TextEditingController(
      text: promotion == null ||
              promotion.discountType == PromotionDiscountType.freeShipping
          ? ''
          : promotion.discountValue.toString(),
    );

    _minOrderAmountController = TextEditingController(
      text: promotion?.minOrderAmount?.toString() ?? '',
    );

    _maxDiscountAmountController = TextEditingController(
      text: promotion?.maxDiscountAmount?.toString() ?? '',
    );

    _discountType = promotion?.discountType ?? PromotionDiscountType.percent;
    _branchScope = promotion?.branchScope ?? PromotionBranchScope.allBranches;
    _active = promotion?.active ?? true;

    _startsAt = promotion?.startsAt;
    _expiresAt = promotion?.expiresAt;

    _selectedBranchIds.addAll(promotion?.selectedBranchIds ?? []);
    _selectedBranchNames.addAll(promotion?.selectedBranchNames ?? []);

    if (!_isPercent) {
      _maxDiscountAmountController.clear();
    }

    if (_isFreeShipping) {
      _discountValueController.clear();
    }

    _validateDates();
    _loadBranches();
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

  Future<void> _loadBranches() async {
    setState(() {
      _loadingBranches = true;
      _branchErrorMessage = null;
    });

    try {
      final branches = await _branchApiService.getBranches();

      if (!mounted) return;

      final activeBranches = branches
          .where((branch) => branch.status == BranchStatus.active)
          .toList();

      setState(() {
        _availableBranches
          ..clear()
          ..addAll(activeBranches);

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
      lastDate: DateTime(now.year + 10),
    );

    if (!mounted || pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );

    if (!mounted || pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  bool _validateDates() {
    if (_startsAt != null &&
        _expiresAt != null &&
        _startsAt!.isAfter(_expiresAt!)) {
      _dateError = 'Valid From must be before Valid To';
      return false;
    }

    _dateError = null;
    return true;
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _discountValueValidator(String? value) {
    if (_isFreeShipping) return null;

    final requiredError = _required(value, 'Discount Value');
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed <= 0) {
      return 'Discount Value must be greater than 0';
    }

    if (_isPercent && parsed > 100) {
      return 'Percent discount cannot be greater than 100';
    }

    return null;
  }

  String? _optionalPositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  void _toggleBranch(BranchEntity branch, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedBranchIds.contains(branch.id)) {
          _selectedBranchIds.add(branch.id);
          _selectedBranchNames.add(branch.name);
        }
      } else {
        _selectedBranchIds.remove(branch.id);
        _selectedBranchNames.remove(branch.name);
      }
    });
  }

  void _savePromotion(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateDates()) {
      setState(() {});
      return;
    }

    if (_branchScope == PromotionBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one branch')),
      );
      return;
    }

    final promotion = PromotionEntity(
      id: widget.promotion?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      discountType: _discountType,
      discountValue: _isFreeShipping
          ? 0
          : double.parse(_discountValueController.text.trim()),
      minOrderAmount: _parseDouble(_minOrderAmountController.text),
      maxDiscountAmount: _isPercent
          ? _parseDouble(_maxDiscountAmountController.text)
          : null,
      startsAt: _startsAt,
      expiresAt: _expiresAt,
      active: _active,
      branchScope: _branchScope,
      selectedBranchIds: _branchScope == PromotionBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchIds),
      selectedBranchNames: _branchScope == PromotionBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchNames),
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
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: state.saving ? null : _cancel,
              ),
              title: Text(
                _isEditMode ? 'Edit Promotion' : 'Create Promotion',
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 24,
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
                            hintText: 'Ramadan Wholesale Deal',
                            validator: (value) {
                              return _required(value, 'Promotion Title');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Description'),
                          _InputField(
                            controller: _descriptionController,
                            hintText: 'Describe this promotion',
                            maxLines: 2,
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Discount Type *'),
                          _DiscountTypeDropdown(
                            value: _discountType,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _discountType = value;

                                if (!_isPercent) {
                                  _maxDiscountAmountController.clear();
                                }

                                if (_isFreeShipping) {
                                  _discountValueController.clear();
                                }
                              });
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(
                            _isPercent
                                ? 'Discount Value (%) *'
                                : 'Discount Value *',
                          ),
                          _InputField(
                            controller: _discountValueController,
                            hintText: _isFreeShipping ? 'Not required' : '15',
                            enabled: !_isFreeShipping,
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
                        title: 'Promotion Rules',
                        children: [
                          _FieldLabel('Min Order Amount'),
                          _InputField(
                            controller: _minOrderAmountController,
                            hintText: '100',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalPositiveNumber(
                                value,
                                'Min Order Amount',
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Max Discount Amount'),
                          _InputField(
                            controller: _maxDiscountAmountController,
                            hintText: _isPercent
                                ? '50'
                                : 'Only for percent promotions',
                            enabled: _isPercent,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalPositiveNumber(
                                value,
                                'Max Discount Amount',
                              );
                            },
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
                              Text(
                                _branchErrorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              )
                            else if (_availableBranches.isEmpty)
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
                                children: _availableBranches.map((branch) {
                                  final selected =
                                      _selectedBranchIds.contains(branch.id);

                                  return FilterChip(
                                    selected: selected,
                                    label: Text(branch.name),
                                    selectedColor: primary.withOpacity(0.15),
                                    checkmarkColor: primary,
                                    onSelected: (isSelected) {
                                      _toggleBranch(branch, isSelected);
                                    },
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 10),
                            const Text(
                              'Selected branches are loaded from the backend Branch Management module.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppThemeTokens.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Validity',
                        children: [
                          _DateTimePickerRow(
                            label: 'Valid From',
                            value: _formatDateTime(_startsAt),
                            onPick: () async {
                              final picked = await _pickDateTime(_startsAt);

                              if (picked == null) return;

                              setState(() {
                                _startsAt = picked;
                                _validateDates();
                              });
                            },
                            onClear: () {
                              setState(() {
                                _startsAt = null;
                                _validateDates();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _DateTimePickerRow(
                            label: 'Valid To',
                            value: _formatDateTime(_expiresAt),
                            onPick: () async {
                              final picked = await _pickDateTime(_expiresAt);

                              if (picked == null) return;

                              setState(() {
                                _expiresAt = picked;
                                _validateDates();
                              });
                            },
                            onClear: () {
                              setState(() {
                                _expiresAt = null;
                                _validateDates();
                              });
                            },
                          ),
                          if (_dateError != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _dateError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
                                activeColor: Colors.white,
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
      value: value,
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
      value: value,
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
  );
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
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppThemeTokens.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
      ],
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
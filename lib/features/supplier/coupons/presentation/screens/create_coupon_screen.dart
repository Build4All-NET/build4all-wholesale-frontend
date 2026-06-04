import 'package:flutter/material.dart';


import '../../../../../core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../branches/data/services/branch_api_service.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../domain/entities/coupon_entity.dart';
import '../bloc/coupons_bloc.dart';
import '../bloc/coupons_event.dart';
import '../bloc/coupons_state.dart';


class CreateCouponScreen extends StatelessWidget {
  final CouponEntity? coupon;


  const CreateCouponScreen({
    super.key,
    this.coupon,
  });


  @override
  Widget build(BuildContext context) {
    return BlocProvider<CouponsBloc>(
      create: (_) => sl<CouponsBloc>(),
      child: _CreateCouponView(coupon: coupon),
    );
  }
}


class _CreateCouponView extends StatefulWidget {
  final CouponEntity? coupon;


  const _CreateCouponView({
    this.coupon,
  });


  @override
  State<_CreateCouponView> createState() => _CreateCouponViewState();
}


class _CreateCouponViewState extends State<_CreateCouponView> {
  final _formKey = GlobalKey<FormState>();


  final BranchApiService _branchApiService = sl<BranchApiService>();


  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _maxUsesController;
  late final TextEditingController _minOrderAmountController;
  late final TextEditingController _maxDiscountAmountController;


  CouponDiscountType _discountType = CouponDiscountType.percent;
  CouponBranchScope _branchScope = CouponBranchScope.allBranches;
  bool _active = true;


  DateTime? _startsAt;
  DateTime? _expiresAt;
  String? _dateError;


  bool _loadingBranches = true;
  String? _branchErrorMessage;


  final List<BranchEntity> _availableBranches = [];
  final List<String> _selectedBranchIds = [];
  final List<String> _selectedBranchNames = [];


  bool get _isEditMode => widget.coupon != null;
  bool get _isPercent => _discountType == CouponDiscountType.percent;
  bool get _isFreeShipping => _discountType == CouponDiscountType.freeShipping;


  @override
  void initState() {
    super.initState();


    final coupon = widget.coupon;


    _codeController = TextEditingController(text: coupon?.code ?? '');
    _descriptionController = TextEditingController(
      text: coupon?.description ?? '',
    );
    _discountValueController = TextEditingController(
      text: coupon == null ||
              coupon.discountType == CouponDiscountType.freeShipping
          ? ''
          : coupon.discountValue.toString(),
    );
    _maxUsesController = TextEditingController(
      text: coupon?.maxUses?.toString() ?? '',
    );
    _minOrderAmountController = TextEditingController(
      text: coupon?.minOrderAmount?.toString() ?? '',
    );
    _maxDiscountAmountController = TextEditingController(
      text: coupon?.maxDiscountAmount?.toString() ?? '',
    );


    _discountType = coupon?.discountType ?? CouponDiscountType.percent;
    _branchScope = coupon?.branchScope ?? CouponBranchScope.allBranches;
    _active = coupon?.active ?? true;
    _startsAt = coupon?.startsAt;
    _expiresAt = coupon?.expiresAt;


    _selectedBranchIds.addAll(coupon?.selectedBranchIds ?? []);
    _selectedBranchNames.addAll(coupon?.selectedBranchNames ?? []);


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
    _codeController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _maxUsesController.dispose();
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


  bool _validateDates({bool requireBothDates = false}) {
    if (requireBothDates && _startsAt == null) {
      _dateError = context.l10n.supplierFieldRequired(
        context.l10n.supplierValidFrom,
      );
      return false;
    }


    if (requireBothDates && _expiresAt == null) {
      _dateError = context.l10n.supplierFieldRequired(
        context.l10n.supplierValidTo,
      );
      return false;
    }


    if (_startsAt != null &&
        _expiresAt != null &&
        _startsAt!.isAfter(_expiresAt!)) {
      _dateError = context.l10n.supplierValidFromBeforeValidTo;
      return false;
    }


    _dateError = null;
    return true;
  }


  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }


  int? _parseInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }


  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.supplierFieldRequired(fieldName);
    }


    return null;
  }


  String? _numberValidator(String? value, String fieldName) {
    if (_isFreeShipping && fieldName == context.l10n.supplierDiscountValuePlain) {
      return null;
    }


    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;


    final parsed = double.tryParse(value!.trim());


    if (parsed == null || parsed <= 0) {
      return context.l10n.supplierFieldGreaterThanZero(fieldName);
    }


    if (_isPercent && fieldName == context.l10n.supplierDiscountValuePlain && parsed > 100) {
      return context.l10n.supplierPercentDiscountCannotBeGreaterThan100;
    }


    return null;
  }


  String? _optionalPositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;


    final parsed = double.tryParse(value.trim());


    if (parsed == null || parsed < 0) {
      return context.l10n.supplierFieldValidNumber(fieldName);
    }


    return null;
  }


  String? _optionalPositiveInt(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;


    final parsed = int.tryParse(value.trim());


    if (parsed == null || parsed < 0) {
      return context.l10n.supplierFieldValidNumber(fieldName);
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


  void _saveCoupon(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;


    if (!_validateDates(requireBothDates: true)) {
      setState(() {});
      return;
    }


    if (_branchScope == CouponBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.supplierPleaseSelectAtLeastOneBranch)),
      );
      return;
    }


    final coupon = CouponEntity(
      id: widget.coupon?.id ?? '',
      ownerProjectId: widget.coupon?.ownerProjectId ?? 0,
      code: _codeController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      discountType: _discountType,
      discountValue: _isFreeShipping
          ? 0
          : double.parse(_discountValueController.text.trim()),
      maxUses: _parseInt(_maxUsesController.text),
      usedCount: widget.coupon?.usedCount ?? 0,
      minOrderAmount: _parseDouble(_minOrderAmountController.text),
      maxDiscountAmount: _isPercent
          ? _parseDouble(_maxDiscountAmountController.text)
          : null,
      startsAt: _startsAt,
      expiresAt: _expiresAt,
      active: _active,
      branchScope: _branchScope,
      selectedBranchIds: _branchScope == CouponBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchIds),
      selectedBranchNames: _branchScope == CouponBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchNames),
    );


    if (_isEditMode) {
      context.read<CouponsBloc>().add(UpdateCouponRequested(coupon));
    } else {
      context.read<CouponsBloc>().add(CreateCouponRequested(coupon));
    }
  }


  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-coupons');
    } else {
      context.go('/supplier-dashboard');
    }
  }


  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;


    return BlocListener<CouponsBloc, CouponsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );


          context.read<CouponsBloc>().add(
                const ClearCouponMessageRequested(),
              );
        }


        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );


          context.read<CouponsBloc>().add(
                const ClearCouponMessageRequested(),
              );


          if (_isEditMode) {
            context.go('/supplier-coupons');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<CouponsBloc, CouponsState>(
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
                _isEditMode ? context.l10n.supplierEditCoupon : context.l10n.supplierCreateCoupon,
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
                          child: Text(
                            context.l10n.cancelButton,
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
                              : () => _saveCoupon(context),
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
                                      ? context.l10n.supplierUpdateCoupon
                                      : context.l10n.supplierCreateCoupon,
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
                        title: context.l10n.supplierCouponInformation,
                        children: [
                          _FieldLabel(context.l10n.supplierCouponCode),
                          _InputField(
                            controller: _codeController,
                            hintText: 'SPRING25',
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              return _required(value, context.l10n.supplierCouponCodePlain);
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.descriptionLabel),
                          _InputField(
                            controller: _descriptionController,
                            hintText: context.l10n.supplierCouponDescriptionHint,
                            maxLines: 2,
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierDiscountType),
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
                                ? context.l10n.supplierDiscountValuePercent
                                : context.l10n.supplierDiscountValue,
                          ),
                          _InputField(
                            controller: _discountValueController,
                            hintText: _isFreeShipping ? context.l10n.notRequiredLabel : '25',
                            enabled: !_isFreeShipping,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _numberValidator(
                                value,
                                context.l10n.supplierDiscountValuePlain,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierCouponRules,
                        children: [
                          _FieldLabel(context.l10n.supplierMaxUses),
                          _InputField(
                            controller: _maxUsesController,
                            hintText: '100',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              return _optionalPositiveInt(
                                value,
                                context.l10n.supplierMaxUses,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierMinOrderAmount),
                          _InputField(
                            controller: _minOrderAmountController,
                            hintText: '50',
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalPositiveNumber(
                                value,
                                context.l10n.supplierMinOrderAmount,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierMaxDiscountAmount),
                          _InputField(
                            controller: _maxDiscountAmountController,
                            hintText:
                                _isPercent ? '30' : context.l10n.supplierOnlyForPercentCoupons,
                            enabled: _isPercent,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              return _optionalPositiveNumber(
                                value,
                                context.l10n.supplierMaxDiscountAmount,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierBranchApplicability,
                        children: [
                          _FieldLabel(context.l10n.supplierAppliesTo),
                          _BranchScopeDropdown(
                            value: _branchScope,
                            onChanged: (value) {
                              if (value == null) return;


                              setState(() {
                                _branchScope = value;


                                if (_branchScope ==
                                    CouponBranchScope.allBranches) {
                                  _selectedBranchIds.clear();
                                  _selectedBranchNames.clear();
                                }
                              });
                            },
                          ),
                          if (_branchScope ==
                              CouponBranchScope.selectedBranches) ...[
                            const _DividerSpace(),
                            Row(
                              children: [
                                Expanded(
                                  child: _FieldLabel(context.l10n.supplierSelectBranches),
                                ),
                                TextButton(
                                  onPressed: _loadingBranches
                                      ? null
                                      : _loadBranches,
                                  child: Text(
                                    context.l10n.refreshButton,
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
                              Text(
                                context.l10n.supplierNoActiveBranchesAvailableAddBranchesFirst,
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
                            Text(
                              context.l10n.supplierSelectedBranchesLoadedFromBackendBranchManagement,
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
                        title: context.l10n.supplierValidity,
                        children: [
                          _DateTimePickerRow(
                            label: context.l10n.supplierValidFrom,
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
                            label: context.l10n.supplierValidTo,
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
                              Expanded(
                                child: Text(
                                  context.l10n.activeStatus,
                                  style: TextStyle(
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


class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;


  _SectionCard({
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


  _FieldLabel(this.text);


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
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;


  _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
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
  final CouponDiscountType value;
  final ValueChanged<CouponDiscountType?> onChanged;


  const _DiscountTypeDropdown({
    required this.value,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CouponDiscountType>(
      value: value,
      items: CouponDiscountType.values
          .map(
            (type) => DropdownMenuItem<CouponDiscountType>(
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


class _BranchScopeDropdown extends StatelessWidget {
  final CouponBranchScope value;
  final ValueChanged<CouponBranchScope?> onChanged;


  const _BranchScopeDropdown({
    required this.value,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CouponBranchScope>(
      value: value,
      items: CouponBranchScope.values
          .map(
            (scope) => DropdownMenuItem<CouponBranchScope>(
              value: scope,
              child: Text(_localizedEnumLabel(context, scope.label)),
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




String _localizedEnumLabel(BuildContext context, String label) {
  switch (label) {
    case 'Pickup from Branch':
      return context.l10n.supplierPickupFromBranch;
    case 'Express Delivery':
      return context.l10n.supplierExpressDelivery;
    case 'Standard Delivery':
      return context.l10n.supplierStandardDelivery;
    case 'All Branches':
      return context.l10n.supplierAllBranches;
    case 'Selected Branches':
      return context.l10n.supplierSelectedBranches;
    case 'Percent':
      return context.l10n.supplierPercent;
    case 'Fixed Amount':
      return context.l10n.supplierFixedAmount;
    case 'Fixed':
      return context.l10n.supplierFixed;
    case 'Free Shipping':
      return context.l10n.supplierFreeShipping;
    case 'All Products':
      return context.l10n.supplierAllProducts;
    case 'Product':
      return context.l10n.productLabel;
    case 'Category':
      return context.l10n.categoryLabel;
    case 'SubCategory':
      return context.l10n.subCategoryLabel;
    case 'Subcategory':
      return context.l10n.subcategoryLabel;
    case 'None':
      return context.l10n.noneLabel;
    case 'URL':
      return context.l10n.urlLabel;
    default:
      return label;
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
    final primary = Theme.of(context).colorScheme.primary;
    final hasValue = value != '—';


    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.event_available_outlined,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: hasValue
                                  ? AppThemeTokens.textPrimary
                                  : AppThemeTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppThemeTokens.border,
          ),
          TextButton.icon(
            onPressed: hasValue ? onClear : null,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text(context.l10n.clearButton),
            style: TextButton.styleFrom(
              foregroundColor: AppThemeTokens.textSecondary,
              disabledForegroundColor:
                  AppThemeTokens.textSecondary.withOpacity(0.35),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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


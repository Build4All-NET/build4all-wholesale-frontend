import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../branches/data/services/branch_api_service.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../bloc/shipping_methods_bloc.dart';
import '../bloc/shipping_methods_event.dart';
import '../bloc/shipping_methods_state.dart';

class CreateShippingMethodScreen extends StatelessWidget {
  final ShippingMethodEntity? method;

  const CreateShippingMethodScreen({
    super.key,
    this.method,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShippingMethodsBloc>(
      create: (_) => sl<ShippingMethodsBloc>(),
      child: _CreateShippingMethodView(method: method),
    );
  }
}

class _CreateShippingMethodView extends StatefulWidget {
  final ShippingMethodEntity? method;

  const _CreateShippingMethodView({
    this.method,
  });

  @override
  State<_CreateShippingMethodView> createState() =>
      _CreateShippingMethodViewState();
}

class _CreateShippingMethodViewState extends State<_CreateShippingMethodView> {
  final _formKey = GlobalKey<FormState>();

  final BranchApiService _branchApiService = sl<BranchApiService>();

  late final TextEditingController _nameController;
  late final TextEditingController _costController;
  late final TextEditingController _estimatedTimeController;
  late final TextEditingController _minimumOrderController;
  late final TextEditingController _freeShippingThresholdController;
  late final TextEditingController _notesController;

  ShippingMethodType _methodType = ShippingMethodType.standardDelivery;
  ShippingBranchScope _branchScope = ShippingBranchScope.allBranches;

  String _country = ShippingMethodLocation.lebanon;
  String _region = ShippingMethodLocation.lebanonRegions.first;

  bool _active = true;
  bool _loadingBranches = true;

  String? _branchErrorMessage;

  final List<BranchEntity> _availableBranches = [];
  final List<String> _selectedBranchIds = [];
  final List<String> _selectedBranchNames = [];

  bool get _isEditMode => widget.method != null;

  bool get _isPickup => _methodType == ShippingMethodType.pickup;

  @override
  void initState() {
    super.initState();

    final method = widget.method;

    _nameController = TextEditingController(text: method?.name ?? '');

    _costController = TextEditingController(
      text: method == null || method.isPickup ? '' : method.cost.toString(),
    );

    _estimatedTimeController = TextEditingController(
      text: method == null || method.isPickup
          ? ''
          : method.estimatedDeliveryTime,
    );

    _minimumOrderController = TextEditingController(
      text: method?.minimumOrderAmount?.toString() ?? '',
    );

    _freeShippingThresholdController = TextEditingController(
      text: method?.freeShippingThreshold?.toString() ?? '',
    );

    _notesController = TextEditingController(text: method?.notes ?? '');

    _methodType = method?.methodType ?? ShippingMethodType.standardDelivery;

    _country = method?.country == ShippingMethodLocation.lebanon
        ? ShippingMethodLocation.lebanon
        : ShippingMethodLocation.lebanon;

    _region = ShippingMethodLocation.lebanonRegions.contains(method?.region)
        ? method!.region
        : ShippingMethodLocation.lebanonRegions.first;

    _branchScope = method?.branchScope ?? ShippingBranchScope.allBranches;
    _active = method?.active ?? true;

    _selectedBranchIds.addAll(method?.selectedBranchIds ?? []);
    _selectedBranchNames.addAll(method?.selectedBranchNames ?? []);

    _loadBranches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _estimatedTimeController.dispose();
    _minimumOrderController.dispose();
    _freeShippingThresholdController.dispose();
    _notesController.dispose();
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

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _requiredNonNegativeNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid number';
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

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  void _toggleBranch(BranchEntity branch, bool selected) {
    setState(() {
      if (selected) {
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

  void _handleMethodTypeChanged(ShippingMethodType? value) {
    if (value == null) return;

    setState(() {
      final wasPickup = _isPickup;
      _methodType = value;

      if (_isPickup) {
        _costController.clear();
        _estimatedTimeController.clear();
        _freeShippingThresholdController.clear();
      } else if (wasPickup) {
        _costController.clear();
        _estimatedTimeController.clear();
      }
    });
  }

  void _saveMethod(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_branchScope == ShippingBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one branch'),
        ),
      );
      return;
    }

    final now = DateTime.now();

    final method = ShippingMethodEntity(
      id: widget.method?.id ?? '',
      name: _nameController.text.trim(),
      methodType: _methodType,
      country: _country,
      region: _region,
      cost: _isPickup ? 0 : double.parse(_costController.text.trim()),
      estimatedDeliveryTime: _isPickup
          ? 'Pickup from branch'
          : _estimatedTimeController.text.trim(),
      minimumOrderAmount: _parseOptionalDouble(_minimumOrderController.text),
      freeShippingThreshold: _isPickup
          ? null
          : _parseOptionalDouble(_freeShippingThresholdController.text),
      branchScope: _branchScope,
      selectedBranchIds: _branchScope == ShippingBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchIds),
      selectedBranchNames: _branchScope == ShippingBranchScope.allBranches
          ? []
          : List.unmodifiable(_selectedBranchNames),
      active: _active,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.method?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditMode) {
      context.read<ShippingMethodsBloc>().add(
            UpdateShippingMethodRequested(method),
          );
    } else {
      context.read<ShippingMethodsBloc>().add(
            CreateShippingMethodRequested(method),
          );
    }
  }

  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-shipping');
    } else {
      context.go('/supplier-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<ShippingMethodsBloc, ShippingMethodsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

          context.read<ShippingMethodsBloc>().add(
                const ClearShippingMethodMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-shipping');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<ShippingMethodsBloc, ShippingMethodsState>(
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
                _isEditMode ? 'Edit Shipping Method' : 'Create Shipping Method',
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
                              : () => _saveMethod(context),
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
                                      ? 'Update Method'
                                      : 'Create Method',
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
                        title: 'Shipping Method Information',
                        children: [
                          _FieldLabel('Method Name *'),
                          _InputField(
                            controller: _nameController,
                            hintText: _isPickup
                                ? 'Pickup from branch'
                                : 'Standard Delivery',
                            validator: (value) {
                              return _required(value, 'Method Name');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Method Type *'),
                          _MethodTypeDropdown(
                            value: _methodType,
                            onChanged: _handleMethodTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          _MethodTypeHelpText(
                            methodType: _methodType,
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Country *'),
                          _CountryDropdown(
                            value: _country,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _country = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'For now, supplier shipping is configured for Lebanon only.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Region *'),
                          _RegionDropdown(
                            value: _region,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                _region = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Region defines the delivery coverage area for this shipping method.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                          if (!_isPickup) ...[
                            const _DividerSpace(),
                            _FieldLabel('Shipping Cost *'),
                            _InputField(
                              controller: _costController,
                              hintText: _methodType ==
                                      ShippingMethodType.expressDelivery
                                  ? '10'
                                  : '5',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                return _requiredNonNegativeNumber(
                                  value,
                                  'Shipping Cost',
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Shipping cost is treated as a fixed flat rate for this method.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: AppThemeTokens.textSecondary,
                              ),
                            ),
                            const _DividerSpace(),
                            _FieldLabel('Estimated Delivery Time *'),
                            _InputField(
                              controller: _estimatedTimeController,
                              hintText: _methodType ==
                                      ShippingMethodType.expressDelivery
                                  ? 'Same day / 24 hours'
                                  : '2-3 business days',
                              validator: (value) {
                                return _required(
                                  value,
                                  'Estimated Delivery Time',
                                );
                              },
                            ),
                          ] else ...[
                            const _DividerSpace(),
                            _InfoBox(
                              primary: primary,
                              text:
                                  'Pickup is collected from a supplier branch, so shipping cost and estimated delivery time are not entered manually. The backend saves pickup cost as 0 automatically.',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Rules',
                        children: [
                          _FieldLabel('Minimum Order Amount'),
                          _InputField(
                            controller: _minimumOrderController,
                            hintText: '50',
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
                          if (!_isPickup) ...[
                            const _DividerSpace(),
                            _FieldLabel('Free Shipping Threshold'),
                            _InputField(
                              controller: _freeShippingThresholdController,
                              hintText: '150',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                return _optionalNonNegativeNumber(
                                  value,
                                  'Free Shipping Threshold',
                                );
                              },
                            ),
                          ],
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
                                    ShippingBranchScope.allBranches) {
                                  _selectedBranchIds.clear();
                                  _selectedBranchNames.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selected branches define which supplier branches support this shipping method.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                          if (_branchScope ==
                              ShippingBranchScope.selectedBranches) ...[
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
                        title: 'Status & Notes',
                        children: [
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
                          const _DividerSpace(),
                          _FieldLabel('Notes'),
                          _InputField(
                            controller: _notesController,
                            hintText: _isPickup
                                ? 'Example: Pickup available from selected branch during working hours'
                                : 'Optional notes for this shipping method',
                            maxLines: 3,
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

class _MethodTypeHelpText extends StatelessWidget {
  final ShippingMethodType methodType;

  const _MethodTypeHelpText({
    required this.methodType,
  });

  @override
  Widget build(BuildContext context) {
    final text = switch (methodType) {
      ShippingMethodType.standardDelivery =>
        'Standard delivery is the normal delivery option, usually cheaper and slower, such as 2-3 business days.',
      ShippingMethodType.expressDelivery =>
        'Express delivery is faster and usually more expensive, such as same-day or 24-hour delivery.',
      ShippingMethodType.pickup =>
        'Pickup means the retailer collects the order from selected branch(es). Shipping cost and delivery time are not entered manually.',
    };

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

class _InfoBox extends StatelessWidget {
  final Color primary;
  final String text;

  const _InfoBox({
    required this.primary,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppThemeTokens.textSecondary,
        ),
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
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
        fillColor: AppThemeTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: _border(),
        enabledBorder: _border(),
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

class _MethodTypeDropdown extends StatelessWidget {
  final ShippingMethodType value;
  final ValueChanged<ShippingMethodType?> onChanged;

  const _MethodTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShippingMethodType>(
      initialValue: value,
      items: ShippingMethodType.values
          .map(
            (type) => DropdownMenuItem<ShippingMethodType>(
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

class _CountryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CountryDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: const [
        DropdownMenuItem<String>(
          value: ShippingMethodLocation.lebanon,
          child: Text('Lebanon'),
        ),
      ],
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

class _RegionDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RegionDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: ShippingMethodLocation.lebanonRegions
          .map(
            (region) => DropdownMenuItem<String>(
              value: region,
              child: Text(region),
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
  final ShippingBranchScope value;
  final ValueChanged<ShippingBranchScope?> onChanged;

  const _BranchScopeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ShippingBranchScope>(
      initialValue: value,
      items: ShippingBranchScope.values
          .map(
            (scope) => DropdownMenuItem<ShippingBranchScope>(
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
    errorBorder: border(color: Colors.red),
    focusedErrorBorder: border(color: Colors.red),
  );
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
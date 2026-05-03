import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/branch_mock_store.dart';
import '../../domain/entities/branch_entity.dart';

class AddBranchScreen extends StatefulWidget {
  final BranchEntity? branchToEdit;

  const AddBranchScreen({
    super.key,
    this.branchToEdit,
  });

  bool get isEditMode => branchToEdit != null;

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();

  final _branchNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  BranchStatus _selectedStatus = BranchStatus.active;

  @override
  void initState() {
    super.initState();

    final branch = widget.branchToEdit;

    if (branch != null) {
      _branchNameController.text = branch.name;
      _cityController.text = branch.city;
      _addressController.text = branch.address;
      _phoneController.text = branch.phoneNumber;
      _selectedStatus = branch.status;
    }
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveBranch() {
    if (!_formKey.currentState!.validate()) return;

    final branch = BranchEntity(
      id: widget.branchToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _branchNameController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      status: _selectedStatus,
    );

    if (widget.isEditMode) {
      BranchMockStore.updateBranch(branch);
    } else {
      BranchMockStore.addBranch(branch);
    }

    context.pop(branch);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = widget.isEditMode ? 'Edit Branch' : 'Add Branch';
    final buttonText = widget.isEditMode ? 'Update Branch' : 'Save Branch';

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
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
                  onPressed: _saveBranch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
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
              title: 'Branch Information',
              subtitle:
                  'Create a supplier branch or warehouse used later for inventory and stock allocation.',
              children: [
                _AppTextField(
                  label: 'Branch Name *',
                  hint: 'e.g., Beirut Warehouse',
                  controller: _branchNameController,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) return 'Branch name is required';
                    if (name.length < 3) {
                      return 'Branch name must be at least 3 characters';
                    }
                    if (name.length > 80) {
                      return 'Branch name is too long';
                    }

                    return null;
                  },
                ),
                _AppTextField(
                  label: 'City / Location *',
                  hint: 'e.g., Beirut, Tripoli, Saida',
                  controller: _cityController,
                  validator: (value) {
                    final city = value?.trim() ?? '';

                    if (city.isEmpty) return 'City is required';
                    if (city.length < 2) {
                      return 'City must be at least 2 characters';
                    }
                    if (city.length > 60) {
                      return 'City is too long';
                    }

                    return null;
                  },
                ),
                _AppTextField(
                  label: 'Full Address *',
                  hint: 'e.g., Beirut, Lebanon - Industrial Area',
                  controller: _addressController,
                  maxLines: 3,
                  validator: (value) {
                    final address = value?.trim() ?? '';

                    if (address.isEmpty) return 'Address is required';
                    if (address.length < 8) {
                      return 'Address must be more specific';
                    }
                    if (address.length > 180) {
                      return 'Address is too long';
                    }

                    return null;
                  },
                ),
                _AppTextField(
                  label: 'Phone Number *',
                  hint: 'e.g., +961 1 234 567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) return 'Phone number is required';
                    if (phone.length < 7) {
                      return 'Phone number is too short';
                    }
                    if (phone.length > 20) {
                      return 'Phone number is too long';
                    }

                    return null;
                  },
                ),
                _StatusSelector(
                  selectedStatus: _selectedStatus,
                  onChanged: (status) {
                    if (status == null) return;

                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
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
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
                height: 1.35,
              ),
            ),
          ],
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
              hintStyle: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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

class _StatusSelector extends StatelessWidget {
  final BranchStatus selectedStatus;
  final ValueChanged<BranchStatus?> onChanged;

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
            'Branch Status *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<BranchStatus>(
            initialValue: selectedStatus,
            items: const [
              DropdownMenuItem(
                value: BranchStatus.active,
                child: Text('Active'),
              ),
              DropdownMenuItem(
                value: BranchStatus.inactive,
                child: Text('Inactive'),
              ),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppThemeTokens.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppThemeTokens.radiusSmall,
                ),
                borderSide: BorderSide.none,
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


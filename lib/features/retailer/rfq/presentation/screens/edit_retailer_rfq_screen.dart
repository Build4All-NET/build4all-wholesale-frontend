// This file is intentionally very similar to CreateRetailerRfqScreen.
// It is separated to keep edit logic safe and pre-filled from backend.

import 'dart:io';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/rfq_request_entity.dart';
import '../../domain/repositories/retailer_rfq_repository.dart';
import '../cubit/retailer_rfq_cubit.dart';
import '../cubit/retailer_rfq_state.dart';
import '../widgets/rfq_info_banner.dart';

class EditRetailerRfqScreen extends StatelessWidget {
  final int rfqId;

  const EditRetailerRfqScreen({super.key, required this.rfqId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerRfqCubit>()..loadDetails(rfqId),
      child: _EditRetailerRfqView(rfqId: rfqId),
    );
  }
}

class _EditRetailerRfqView extends StatefulWidget {
  final int rfqId;

  const _EditRetailerRfqView({required this.rfqId});

  @override
  State<_EditRetailerRfqView> createState() => _EditRetailerRfqViewState();
}

class _EditRetailerRfqViewState extends State<_EditRetailerRfqView> {
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedDeliveryValue = 'Within 1 week';
  DateTime? _deadlineDate;
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _aiGenerated = false;
  bool _formFilled = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _requirementsController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    _targetPriceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _fillFormOnce(RfqRequestEntity rfq) {
    if (_formFilled) return;

    _productNameController.text = rfq.productName;
    _requirementsController.text = rfq.requirements;
    _quantityController.text = rfq.quantity.toString();
    _unitController.text = rfq.unit;
    _categoryController.text = rfq.categoryName ?? '';
    _subCategoryController.text = rfq.subCategoryName ?? '';
    _targetPriceController.text = rfq.targetUnitPrice?.toString() ?? '';
    _cityController.text = rfq.deliveryCity ?? '';
    _addressController.text = rfq.deliveryAddress ?? '';

    _existingImageUrl = rfq.imageUrl;
    _deadlineDate = rfq.deadlineDate;
    _aiGenerated = rfq.aiGenerated;

    const allowedDeliveryValues = {
      'Within 24 hours',
      'Within 2-3 days',
      'Within 1 week',
      'Within 2 weeks',
      'Flexible',
    };

    _selectedDeliveryValue =
        allowedDeliveryValues.contains(rfq.preferredDeliveryLabel)
        ? rfq.preferredDeliveryLabel
        : 'Within 1 week';

    _formFilled = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      _pickedImage = picked;
      _existingImageUrl = null;
    });
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _writeWithAiHelper() async {
    final l10n = AppLocalizations.of(context)!;
    final product = _productNameController.text.trim();

    if (product.isEmpty) {
      AppToast.error(context, l10n.rfqAiProductNameRequired);
      return;
    }

    final currentRequirements = _requirementsController.text.trim();

    if (currentRequirements.isNotEmpty) {
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.rfqAiReplaceTitle),
            content: Text(l10n.rfqAiReplaceMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.rfqAiKeepAction),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.rfqAiReplaceAction),
              ),
            ],
          );
        },
      );

      if (shouldReplace != true) return;
    }

    final rfq = context.read<RetailerRfqCubit>().state.selectedRfq;

    final generated = await context
        .read<RetailerRfqCubit>()
        .generateRequirementsWithAi(
          GenerateRfqRequirementsParams(
            productId: rfq?.productId,
            productName: _productNameController.text.trim(),
            categoryName: _emptyToNull(_categoryController.text),
            subCategoryName: _emptyToNull(_subCategoryController.text),
            quantity: int.tryParse(_quantityController.text.trim()),
            unit: _unitController.text.trim().isEmpty
                ? 'units'
                : _unitController.text.trim(),
            targetUnitPrice: _parseDouble(_targetPriceController.text),
            preferredDeliveryLabel: _selectedDeliveryValue,
            deliveryCity: _emptyToNull(_cityController.text),
            deliveryAddress: _emptyToNull(_addressController.text),
            notes: currentRequirements.isEmpty ? null : currentRequirements,
          ),
        );

    if (generated == null || !mounted) return;

    setState(() {
      _requirementsController.text = generated;
      _aiGenerated = true;
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selected == null) return;

    setState(() => _deadlineDate = selected);
  }

  Future<void> _submit(RfqRequestEntity rfq) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = await context.read<RetailerRfqCubit>().updateRfq(
      rfqId: rfq.id,
      params: UpdateRfqParams(
        productName: _productNameController.text.trim(),
        requirements: _requirementsController.text.trim(),
        imagePath: _pickedImage?.path,
        imageUrl: _existingImageUrl,
        categoryName: _emptyToNull(_categoryController.text),
        subCategoryName: _emptyToNull(_subCategoryController.text),
        quantity: int.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim().isEmpty
            ? 'units'
            : _unitController.text.trim(),
        targetUnitPrice: _parseDouble(_targetPriceController.text),
        preferredDeliveryLabel: _selectedDeliveryValue,
        preferredDeliveryDays: _deliveryDays(_selectedDeliveryValue),
        deadlineDate: _deadlineDate,
        deliveryCity: _emptyToNull(_cityController.text),
        deliveryAddress: _emptyToNull(_addressController.text),
        aiGenerated: _aiGenerated,
      ),
    );

    if (updated == null || !mounted) return;

    context.go('/retailer-rfqs/${updated.id}');
  }

  String? _emptyToNull(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return null;
    return clean;
  }

  double? _parseDouble(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return null;
    return double.tryParse(clean);
  }

  int? _deliveryDays(String value) {
    return switch (value) {
      'Within 24 hours' => 1,
      'Within 2-3 days' => 3,
      'Within 1 week' => 7,
      'Within 2 weeks' => 14,
      'Flexible' => null,
      _ => null,
    };
  }

  List<_DeliveryOption> _deliveryOptions(AppLocalizations l10n) {
    return [
      _DeliveryOption(
        value: 'Within 24 hours',
        label: l10n.rfqDeliveryWithin24Hours,
      ),
      _DeliveryOption(
        value: 'Within 2-3 days',
        label: l10n.rfqDelivery2To3Days,
      ),
      _DeliveryOption(
        value: 'Within 1 week',
        label: l10n.rfqDeliveryWithin1Week,
      ),
      _DeliveryOption(
        value: 'Within 2 weeks',
        label: l10n.rfqDeliveryWithin2Weeks,
      ),
      _DeliveryOption(value: 'Flexible', label: l10n.rfqDeliveryFlexible),
    ];
  }

  String? _buildImageUrl(String? value) {
    final clean = value?.trim();

    if (clean == null || clean.isEmpty) return null;

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    final base = AppConfig.projectApiBaseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    if (clean.startsWith('/')) {
      return '$base$clean';
    }

    return '$base/$clean';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RetailerRfqCubit, RetailerRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.error(context, state.errorMessage!);
          context.read<RetailerRfqCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final rfq = state.selectedRfq;

        if (rfq != null) {
          _fillFormOnce(rfq);
        }

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l10n.rfqEdit,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          bottomNavigationBar: rfq == null
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: ElevatedButton.icon(
                      onPressed: state.isSubmitting || !rfq.canEdit
                          ? null
                          : () => _submit(rfq),
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        state.isSubmitting
                            ? l10n.rfqSavingChanges
                            : l10n.rfqSaveChanges,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
          body: state.isLoading && rfq == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : rfq == null
              ? Center(
                  child: Text(
                    l10n.rfqNotFound,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : !rfq.canEdit
              ? _NotEditableView(rfq: rfq)
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      const RfqInfoBanner(),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: l10n.rfqProductRequest,
                        children: [
                          _TextFieldBox(
                            controller: _productNameController,
                            label: l10n.rfqProductName,
                            hint: l10n.rfqProductNameHint,
                            icon: Icons.inventory_2_outlined,
                            validator: (value) {
                              final clean = value?.trim() ?? '';
                              if (clean.isEmpty) {
                                return l10n.rfqProductNameRequired;
                              }
                              if (clean.length < 2) {
                                return l10n.rfqProductNameTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _ImagePickerBox(
                            pickedImage: _pickedImage,
                            existingImageUrl: _buildImageUrl(_existingImageUrl),
                            onPick: _pickImage,
                            onRemove: _removeImage,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _TextFieldBox(
                                  controller: _categoryController,
                                  label: l10n.rfqCategory,
                                  hint: l10n.rfqCategoryHint,
                                  icon: Icons.category_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TextFieldBox(
                                  controller: _subCategoryController,
                                  label: l10n.rfqSubcategory,
                                  hint: l10n.rfqSubcategoryHint,
                                  icon: Icons.account_tree_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: l10n.rfqDetailedRequirements,
                        children: [
                          _MultilineFieldBox(
                            controller: _requirementsController,
                            label: l10n.rfqRequirements,
                            hint: l10n.rfqRequirementsHint,
                            validator: (value) {
                              final clean = value?.trim() ?? '';
                              if (clean.isEmpty) {
                                return l10n.rfqRequirementsRequired;
                              }
                              if (clean.length < 10) {
                                return l10n.rfqRequirementsTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: state.isAiWriting
                                ? null
                                : _writeWithAiHelper,
                            icon: state.isAiWriting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(
                              state.isAiWriting
                                  ? l10n.rfqWritingWithAi
                                  : l10n.rfqWriteWithAi,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: l10n.rfqQuantityAndDelivery,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _TextFieldBox(
                                  controller: _quantityController,
                                  label: l10n.rfqMinimumQuantity,
                                  hint: l10n.rfqMinimumQuantityHint,
                                  icon: Icons.numbers_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final quantity = int.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (quantity == null || quantity <= 0) {
                                      return l10n.rfqEnterValidQuantity;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TextFieldBox(
                                  controller: _unitController,
                                  label: l10n.rfqUnit,
                                  hint: l10n.rfqUnitHint,
                                  icon: Icons.straighten_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TextFieldBox(
                            controller: _targetPriceController,
                            label: l10n.rfqTargetUnitPrice,
                            hint: l10n.rfqOptional,
                            icon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DeliveryDropdown(
                            selectedValue: _selectedDeliveryValue,
                            options: _deliveryOptions(l10n),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedDeliveryValue = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          _DeadlineBox(
                            date: _deadlineDate,
                            onPick: _pickDeadline,
                            onClear: () => setState(() => _deadlineDate = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: l10n.rfqDeliveryLocation,
                        children: [
                          _TextFieldBox(
                            controller: _cityController,
                            label: l10n.rfqCity,
                            hint: l10n.rfqCityHint,
                            icon: Icons.location_city_outlined,
                          ),
                          const SizedBox(height: 12),
                          _MultilineFieldBox(
                            controller: _addressController,
                            label: l10n.rfqDeliveryAddress,
                            hint: l10n.rfqDeliveryAddressHint,
                            minLines: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _NotEditableView extends StatelessWidget {
  final RfqRequestEntity rfq;

  const _NotEditableView({required this.rfq});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.rfqCannotEditTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rfq.hasSupplierQuotations
                  ? l10n.rfqCannotEditSupplierMessage
                  : l10n.rfqCannotEditStatusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.go('/retailer-rfqs/${rfq.id}'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.rfqBackToDetails),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextFieldBox({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(
        context: context,
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }
}

class _MultilineFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final String? Function(String?)? validator;

  const _MultilineFieldBox({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 4,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: 8,
      validator: validator,
      decoration: _inputDecoration(
        context: context,
        label: label,
        hint: hint,
        icon: Icons.notes_outlined,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required BuildContext context,
  required String label,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: AppThemeTokens.inputFill,
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
        width: 1.5,
      ),
    ),
  );
}

class _ImagePickerBox extends StatelessWidget {
  final XFile? pickedImage;
  final String? existingImageUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerBox({
    required this.pickedImage,
    required this.existingImageUrl,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasNewImage = pickedImage != null;
    final hasExistingImage =
        existingImageUrl != null && existingImageUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasNewImage || hasExistingImage
                ? Theme.of(context).colorScheme.primary
                : AppThemeTokens.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasNewImage
            ? _ImagePreview(
                child: Image.file(
                  File(pickedImage!.path),
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
                onRemove: onRemove,
              )
            : hasExistingImage
            ? _ImagePreview(
                child: Image.network(
                  existingImageUrl!,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
                onRemove: onRemove,
              )
            : Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42,
                      color: AppThemeTokens.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.rfqUploadProductImage,
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.rfqUploadProductImageHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImagePreview({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 10,
          right: 10,
          child: IconButton.filled(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

class _DeliveryDropdown extends StatelessWidget {
  final String selectedValue;
  final List<_DeliveryOption> options;
  final ValueChanged<String?> onChanged;

  const _DeliveryDropdown({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option.value,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(
        context: context,
        label: l10n.rfqPreferredDeliveryTime,
        hint: l10n.rfqChooseDeliveryTime,
        icon: Icons.local_shipping_outlined,
      ),
    );
  }
}

class _DeadlineBox extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DeadlineBox({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final label = date == null
        ? l10n.rfqSelectDeadlineDate
        : '${date!.day.toString().padLeft(2, '0')}/'
              '${date!.month.toString().padLeft(2, '0')}/'
              '${date!.year}';

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_outlined,
              color: AppThemeTokens.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: date == null
                      ? AppThemeTokens.textSecondary
                      : AppThemeTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (date != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOption {
  final String value;
  final String label;

  const _DeliveryOption({required this.value, required this.label});
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
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

  final _deliveryOptions = const [
    _DeliveryOption(label: 'Within 24 hours', days: 1),
    _DeliveryOption(label: 'Within 2-3 days', days: 3),
    _DeliveryOption(label: 'Within 1 week', days: 7),
    _DeliveryOption(label: 'Within 2 weeks', days: 14),
    _DeliveryOption(label: 'Flexible', days: null),
  ];

  _DeliveryOption _selectedDelivery = const _DeliveryOption(
    label: 'Within 1 week',
    days: 7,
  );

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

    _selectedDelivery = _deliveryOptions.firstWhere(
      (option) => option.label == rfq.preferredDeliveryLabel,
      orElse: () => _DeliveryOption(
        label: rfq.preferredDeliveryLabel,
        days: rfq.preferredDeliveryDays,
      ),
    );

    _formFilled = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
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

  void _writeWithAiHelper() {
    final product = _productNameController.text.trim();

    if (product.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write the product name first.')),
      );
      return;
    }

    final category = _categoryController.text.trim();

    final generated = [
      'I am requesting a quotation for $product.',
      if (category.isNotEmpty) 'Category: $category.',
      'Please provide wholesale pricing, available quantity, product quality details, packaging information, and expected delivery time.',
      'The quotation should include unit price, shipping cost if applicable, and any minimum order requirements.',
    ].join('\n');

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
        preferredDeliveryLabel: _selectedDelivery.label,
        preferredDeliveryDays: _selectedDelivery.days,
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
    return BlocConsumer<RetailerRfqCubit, RetailerRfqState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
            title: const Text(
              'Edit RFQ',
              style: TextStyle(
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
                            ? 'Saving changes...'
                            : 'Save changes',
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
              ? const Center(
                  child: Text(
                    'RFQ not found',
                    style: TextStyle(
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
                        title: 'Product request',
                        children: [
                          _TextFieldBox(
                            controller: _productNameController,
                            label: 'Product name *',
                            hint: 'Example: Organic milk cartons',
                            icon: Icons.inventory_2_outlined,
                            validator: (value) {
                              final clean = value?.trim() ?? '';
                              if (clean.isEmpty) {
                                return 'Product name is required';
                              }
                              if (clean.length < 2) {
                                return 'Product name must be at least 2 characters';
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
                                  label: 'Category',
                                  hint: 'Food, Electronics...',
                                  icon: Icons.category_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TextFieldBox(
                                  controller: _subCategoryController,
                                  label: 'Subcategory',
                                  hint: 'Dairy, Phones...',
                                  icon: Icons.account_tree_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Detailed requirements',
                        children: [
                          _MultilineFieldBox(
                            controller: _requirementsController,
                            label: 'Requirements *',
                            hint:
                                'Describe specs, quality, packaging, preferred brands, size, color, standards...',
                            validator: (value) {
                              final clean = value?.trim() ?? '';
                              if (clean.isEmpty) {
                                return 'Requirements are required';
                              }
                              if (clean.length < 10) {
                                return 'Requirements must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _writeWithAiHelper,
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(
                              _aiGenerated
                                  ? 'AI suggestion added'
                                  : 'Write with AI',
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
                        title: 'Quantity and delivery',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _TextFieldBox(
                                  controller: _quantityController,
                                  label: 'Minimum quantity *',
                                  hint: '500',
                                  icon: Icons.numbers_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final quantity = int.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (quantity == null || quantity <= 0) {
                                      return 'Enter valid quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TextFieldBox(
                                  controller: _unitController,
                                  label: 'Unit',
                                  hint: 'units',
                                  icon: Icons.straighten_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TextFieldBox(
                            controller: _targetPriceController,
                            label: 'Target unit price',
                            hint: 'Optional',
                            icon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DeliveryDropdown(
                            selected: _selectedDelivery,
                            options: _deliveryOptions,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedDelivery = value);
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
                        title: 'Delivery location',
                        children: [
                          _TextFieldBox(
                            controller: _cityController,
                            label: 'City',
                            hint: 'Example: Beirut',
                            icon: Icons.location_city_outlined,
                          ),
                          const SizedBox(height: 12),
                          _MultilineFieldBox(
                            controller: _addressController,
                            label: 'Delivery address',
                            hint: 'Street, building, area, notes...',
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
            const Text(
              'This RFQ cannot be edited',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rfq.hasSupplierQuotations
                  ? 'A supplier has already interacted with this request. To keep quotations fair and valid, cancel the RFQ and create a new one if you need changes.'
                  : 'This RFQ status does not allow editing.',
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
              label: const Text('Back to details'),
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
            : const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42,
                      color: AppThemeTokens.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload product image',
                      style: TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Optional. This photo will also appear for suppliers when they view your RFQ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
  final _DeliveryOption selected;
  final List<_DeliveryOption> options;
  final ValueChanged<_DeliveryOption?> onChanged;

  const _DeliveryDropdown({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_DeliveryOption>(
      value: selected,
      items: options
          .map(
            (option) =>
                DropdownMenuItem(value: option, child: Text(option.label)),
          )
          .toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(
        context: context,
        label: 'Preferred delivery time',
        hint: 'Choose delivery time',
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
    final label = date == null
        ? 'Select deadline date'
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
  final String label;
  final int? days;

  const _DeliveryOption({required this.label, required this.days});
}

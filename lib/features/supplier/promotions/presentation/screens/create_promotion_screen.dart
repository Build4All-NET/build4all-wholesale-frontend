import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common/widgets/primary_button.dart';
import '../../../../../common/widgets/primary_dropdown_field.dart';
import '../../../../../common/widgets/primary_text_field.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/promotion_mock_store.dart';
import '../../domain/entities/promotion_entity.dart';

class CreatePromotionScreen extends StatefulWidget {
  final PromotionEntity? promotion;

  const CreatePromotionScreen({
    super.key,
    this.promotion,
  });

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _discountController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  String? _selectedDiscountType;
  String? _selectedStatus;

  bool get _isEditMode => widget.promotion != null;

  final List<String> _discountTypes = const [
    'Percentage',
    'Fixed Amount',
  ];

  final List<String> _statuses = const [
    'Draft',
    'Active',
    'Inactive',
  ];

  @override
  void initState() {
    super.initState();

    final promotion = widget.promotion;

    _titleController = TextEditingController(text: promotion?.title ?? '');
    _descriptionController = TextEditingController(
      text: promotion?.description ?? '',
    );
    _discountController = TextEditingController(
      text: promotion?.discountLabel.replaceAll('%', '').replaceAll('\$', '') ??
          '',
    );
    _startDateController = TextEditingController(
      text: promotion?.startDate == '-' ? '' : promotion?.startDate ?? '',
    );
    _endDateController = TextEditingController(
      text: promotion?.endDate == '-' ? '' : promotion?.endDate ?? '',
    );

    _selectedDiscountType =
        promotion?.discountLabel.contains('%') == true ? 'Percentage' : 'Fixed Amount';
    _selectedStatus = promotion?.status ?? 'Draft';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _pickDate(
    TextEditingController controller, {
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate ?? now,
      firstDate: firstDate ?? now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    controller.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final discountValue = _discountController.text.trim();

    final promotion = PromotionEntity(
      id: widget.promotion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      discountLabel: _selectedDiscountType == 'Percentage'
          ? '$discountValue%'
          : '\$$discountValue',
      status: _selectedStatus ?? 'Draft',
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
    );

    if (_isEditMode) {
      PromotionMockStore.updatePromotion(promotion);
    } else {
      PromotionMockStore.addPromotion(promotion);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Promotion updated successfully'
              : 'Promotion saved successfully',
        ),
      ),
    );

    context.go('/supplier-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/supplier-promotions'),
        ),
        centerTitle: true,
        title: Text(
          _isEditMode ? 'Edit Promotion' : 'Create Promotion',
          style: TextStyle(
            color: primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppThemeTokens.surface,
            border: Border(top: BorderSide(color: AppThemeTokens.border)),
          ),
          child: PrimaryButton(
            text: _isEditMode ? 'Update Promotion' : 'Save Promotion',
            onPressed: _submit,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeTokens.surface,
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    primary: primary,
                    title: _isEditMode ? 'Edit Promotion' : 'New Promotion',
                    subtitle: _isEditMode
                        ? 'Update this promotional offer.'
                        : 'Create a new offer for retailers.',
                  ),
                  const SizedBox(height: 28),

                  const _FieldLabel('Promotion Title'),
                  PrimaryTextField(
                    controller: _titleController,
                    hintText: 'Enter promotion title',
                    validator: (value) => _required(value, 'Promotion Title'),
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('Description'),
                  PrimaryTextField(
                    controller: _descriptionController,
                    hintText: 'Describe the promotion',
                    maxLines: 4,
                    validator: (value) => _required(value, 'Description'),
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('Discount Type'),
                  PrimaryDropdownField<String>(
                    value: _selectedDiscountType,
                    hintText: 'Select discount type',
                    items: _discountTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDiscountType = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Discount Type is required'
                        : null,
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('Discount Value'),
                  PrimaryTextField(
                    controller: _discountController,
                    hintText: 'Example: 15',
                    keyboardType: TextInputType.number,
                    validator: (value) => _required(value, 'Discount Value'),
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('Start Date'),
                  PrimaryTextField(
                    controller: _startDateController,
                    hintText: 'Select start date',
                    readOnly: true,
                    prefixIcon: const Icon(Icons.date_range_outlined),
                    onTap: () {
                      _endDateController.clear();
                      _pickDate(_startDateController);
                    },
                    validator: (value) => _required(value, 'Start Date'),
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('End Date'),
                  PrimaryTextField(
                    controller: _endDateController,
                    hintText: 'Select end date',
                    readOnly: true,
                    prefixIcon: const Icon(Icons.date_range_outlined),
                    onTap: () {
                      if (_startDateController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select start date first'),
                          ),
                        );
                        return;
                      }

                      final startDate = DateTime.parse(
                        _startDateController.text,
                      );

                      _pickDate(_endDateController, firstDate: startDate);
                    },
                    validator: (value) => _required(value, 'End Date'),
                  ),

                  const SizedBox(height: 18),

                  const _FieldLabel('Status'),
                  PrimaryDropdownField<String>(
                    value: _selectedStatus,
                    hintText: 'Select status',
                    items: _statuses
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Status is required'
                        : null,
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color primary;
  final String title;
  final String subtitle;

  const _Header({
    required this.primary,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: primary.withOpacity(0.12),
          child: Icon(Icons.local_offer_outlined, color: primary, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_rfq_quotation_entity.dart';
import '../../domain/repositories/supplier_rfq_repository.dart';
import '../utils/supplier_rfq_i18n.dart';

class SupplierQuotationFormDialog extends StatefulWidget {
  final SupplierRfqQuotationEntity? quotation;

  const SupplierQuotationFormDialog({super.key, this.quotation});

  @override
  State<SupplierQuotationFormDialog> createState() => _SupplierQuotationFormDialogState();
}

class _SupplierQuotationFormDialogState extends State<SupplierQuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitPriceController;
  late final TextEditingController _availableQuantityController;
  late final TextEditingController _shippingCostController;
  late final TextEditingController _messageController;
  DateTime? _deliveryDate;

  bool get _isEditing => widget.quotation != null;

  @override
  void initState() {
    super.initState();
    final quotation = widget.quotation;
    _unitPriceController = TextEditingController(
      text: quotation == null ? '' : _trimDouble(quotation.unitPrice),
    );
    _availableQuantityController = TextEditingController(
      text: quotation?.availableQuantity?.toString() ?? '',
    );
    _shippingCostController = TextEditingController(
      text: quotation == null ? '0' : _trimDouble(quotation.shippingCost ?? 0),
    );
    _messageController = TextEditingController(text: quotation?.message ?? '');
    _deliveryDate = quotation?.deliveryDate;
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _availableQuantityController.dispose();
    _shippingCostController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = SupplierRfqI18n(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? l.t('editQuotation') : l.t('submitQuotationSmall'),
                        style: const TextStyle(
                          color: AppThemeTokens.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _NumberField(
                  controller: _unitPriceController,
                  label: "${l.t('unitPrice')} *",
                  hint: 'Example: 12.50',
                  validator: (value) => _positiveDoubleValidator(value, l.t('unitPrice')),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  controller: _availableQuantityController,
                  label: "${l.t('availableQuantity')} *",
                  hint: 'Example: 500',
                  allowDecimal: false,
                  validator: (value) => _positiveIntValidator(value, l.t('availableQuantity')),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDeliveryDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _inputDecoration(l.t('deliveryDate')),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _deliveryDate == null
                                ? l.t('deliveryDate')
                                : _formatDate(_deliveryDate!),
                            style: TextStyle(
                              color: _deliveryDate == null
                                  ? AppThemeTokens.textSecondary
                                  : AppThemeTokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _NumberField(
                  controller: _shippingCostController,
                  label: "${l.t('shippingCost')} *",
                  hint: '0 for free shipping',
                  validator: (value) => _nonNegativeDoubleValidator(value, l.t('shippingCost')),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _inputDecoration(l.t('messageNotes')),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_isEditing ? l.t('updateQuotation') : l.t('submitQuotationSmall')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppThemeTokens.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppThemeTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppThemeTokens.border),
      ),
    );
  }

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (selected != null) setState(() => _deliveryDate = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final params = SupplierQuotationParams(
      unitPrice: double.parse(_unitPriceController.text.trim()),
      availableQuantity: int.parse(_availableQuantityController.text.trim()),
      deliveryDate: _deliveryDate,
      shippingCost: double.parse(_shippingCostController.text.trim()),
      message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
    );

    Navigator.of(context).pop(params);
  }

  String? _positiveDoubleValidator(String? value, String label) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return '$label ${SupplierRfqI18n(context).t('mustBeGreaterThanZero')}';
    return null;
  }

  String? _nonNegativeDoubleValidator(String? value, String label) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) return '$label ${SupplierRfqI18n(context).t('cannotBeNegative')}';
    return null;
  }

  String? _positiveIntValidator(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return '$label ${SupplierRfqI18n(context).t('mustBeGreaterThanZero')}';
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _trimDouble(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool allowDecimal;
  final String? Function(String?) validator;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    this.allowDecimal = true,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
        ),
      ],
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppThemeTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppThemeTokens.border),
        ),
      ),
    );
  }
}

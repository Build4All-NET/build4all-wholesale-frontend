import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/coupon_mock_store.dart';
import '../../domain/entities/coupon_entity.dart';

class CreateCouponScreen extends StatefulWidget {
  final CouponEntity? coupon;

  const CreateCouponScreen({
    super.key,
    this.coupon,
  });

  @override
  State<CreateCouponScreen> createState() => _CreateCouponScreenState();
}

class _CreateCouponScreenState extends State<CreateCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _couponCodeController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _usageLimitController;

  late String _discountType;
  late bool _isActive;

  bool get _isEditMode => widget.coupon != null;

  final List<String> _discountTypes = const [
    'Percentage',
    'Fixed',
  ];

  @override
  void initState() {
    super.initState();

    final coupon = widget.coupon;

    _couponCodeController = TextEditingController(
      text: coupon?.code ?? '',
    );

    _discountValueController = TextEditingController(
      text: coupon == null ? '' : coupon.discountValue.toStringAsFixed(0),
    );

    _expiryDateController = TextEditingController(
      text: coupon?.expiryDate ?? '',
    );

    _usageLimitController = TextEditingController(
      text: coupon?.usageLimit?.toString() ?? '',
    );

    _discountType = coupon?.discountType ?? 'Percentage';
    _isActive = coupon?.isActive ?? true;
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    _discountValueController.dispose();
    _expiryDateController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _positiveNumber(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);
    if (requiredError != null) return requiredError;

    final number = double.tryParse(value!.trim());

    if (number == null || number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    _expiryDateController.text = _formatDate(picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveCoupon() {
    if (!_formKey.currentState!.validate()) return;

    final coupon = CouponEntity(
      id: widget.coupon?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: _couponCodeController.text.trim().toUpperCase(),
      discountType: _discountType,
      discountValue: double.parse(_discountValueController.text.trim()),
      expiryDate: _expiryDateController.text.trim(),
      usageLimit: _usageLimitController.text.trim().isEmpty
          ? null
          : int.tryParse(_usageLimitController.text.trim()),
      isActive: _isActive,
    );

    if (_isEditMode) {
      CouponMockStore.updateCoupon(coupon);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon updated successfully')),
      );

      context.go('/supplier-coupons');
    } else {
      CouponMockStore.addCoupon(coupon);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon created successfully')),
      );

      context.go('/supplier-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            if (_isEditMode) {
              context.go('/supplier-coupons');
            } else {
              context.go('/supplier-dashboard');
            }
          },
        ),
        title: Text(
          _isEditMode ? 'Edit Coupon' : 'Create Coupon',
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
                    onPressed: () {
                      if (_isEditMode) {
                        context.go('/supplier-coupons');
                      } else {
                        context.go('/supplier-dashboard');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeTokens.textPrimary,
                      backgroundColor: AppThemeTokens.surface,
                      side: const BorderSide(color: AppThemeTokens.border),
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
                    onPressed: _saveCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isEditMode ? 'Update Coupon' : 'Create Coupon',
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
                  title: 'Coupon Information',
                  children: [
                    _FieldLabel('Coupon Code *'),
                    _InputField(
                      controller: _couponCodeController,
                      hintText: 'SPRING25',
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) => _required(value, 'Coupon Code'),
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Discount Type *'),
                    _DropdownField(
                      value: _discountType,
                      items: _discountTypes,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _discountType = value;
                        });
                      },
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Discount Value *'),
                    _InputField(
                      controller: _discountValueController,
                      hintText: '25',
                      keyboardType: TextInputType.number,
                      validator: (value) => _positiveNumber(
                        value,
                        'Discount Value',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SectionCard(
                  title: 'Coupon Settings',
                  children: [
                    _FieldLabel('Expiry Date *'),
                    _InputField(
                      controller: _expiryDateController,
                      hintText: 'Select date',
                      readOnly: true,
                      onTap: _pickExpiryDate,
                      validator: (value) => _required(value, 'Expiry Date'),
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Usage Limit'),
                    _InputField(
                      controller: _usageLimitController,
                      hintText: '100',
                      keyboardType: TextInputType.number,
                    ),
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
                          value: _isActive,
                          activeColor: Colors.white,
                          activeTrackColor: primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFD1D5DB),
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
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
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
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

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: InputDecoration(
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
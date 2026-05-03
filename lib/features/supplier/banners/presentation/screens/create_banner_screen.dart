import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/banner_mock_store.dart';
import '../../domain/entities/banner_entity.dart';

class CreateBannerScreen extends StatefulWidget {
  final BannerEntity? banner;

  const CreateBannerScreen({
    super.key,
    this.banner,
  });

  @override
  State<CreateBannerScreen> createState() => _CreateBannerScreenState();
}

class _CreateBannerScreenState extends State<CreateBannerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _displayOrderController;

  BannerTargetType _targetType = BannerTargetType.none;
  bool _active = true;

  DateTime? _startsAt;
  DateTime? _endsAt;
  String? _dateError;

  bool get _isEditMode => widget.banner != null;
  bool get _targetValueRequired => _targetType != BannerTargetType.none;

  @override
  void initState() {
    super.initState();

    final banner = widget.banner;

    _titleController = TextEditingController(text: banner?.title ?? '');
    _subtitleController = TextEditingController(text: banner?.subtitle ?? '');
    _imageUrlController = TextEditingController(text: banner?.imageUrl ?? '');
    _targetValueController = TextEditingController(
      text: banner?.targetValue ?? '',
    );
    _displayOrderController = TextEditingController(
      text: banner?.displayOrder.toString() ?? '1',
    );

    _targetType = banner?.targetType ?? BannerTargetType.none;
    _active = banner?.active ?? true;
    _startsAt = banner?.startsAt;
    _endsAt = banner?.endsAt;

    _validateDates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _targetValueController.dispose();
    _displayOrderController.dispose();
    super.dispose();
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
    if (_startsAt != null && _endsAt != null && _startsAt!.isAfter(_endsAt!)) {
      _dateError = 'Start Date must be before End Date';
      return false;
    }

    _dateError = null;
    return true;
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final uri = Uri.tryParse(value.trim());

    if (uri == null || !uri.hasScheme) {
      return 'Image URL must be a valid URL';
    }

    return null;
  }

  String? _positiveInt(String? value, String fieldName) {
    final requiredError = _required(value, fieldName);

    if (requiredError != null) return requiredError;

    final parsed = int.tryParse(value!.trim());

    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  void _saveBanner() {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateDates()) {
      setState(() {});
      return;
    }

    final banner = BannerEntity(
      id: widget.banner?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ownerProjectId: widget.banner?.ownerProjectId ?? 0,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      targetType: _targetType,
      targetValue: _targetType == BannerTargetType.none ||
              _targetValueController.text.trim().isEmpty
          ? null
          : _targetValueController.text.trim(),
      displayOrder: int.parse(_displayOrderController.text.trim()),
      startsAt: _startsAt,
      endsAt: _endsAt,
      active: _active,
    );

    if (_isEditMode) {
      BannerMockStore.updateBanner(banner);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner updated successfully')),
      );

      context.go('/supplier-banners');
    } else {
      BannerMockStore.addBanner(banner);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner created successfully')),
      );

      context.go('/supplier-dashboard');
    }
  }

  void _cancel() {
    if (_isEditMode) {
      context.go('/supplier-banners');
    } else {
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
          onPressed: _cancel,
        ),
        title: Text(
          _isEditMode ? 'Edit Banner' : 'Create Banner',
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
                    onPressed: _cancel,
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
                    onPressed: _saveBanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isEditMode ? 'Update Banner' : 'Create Banner',
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
                  title: 'Banner Information',
                  children: [
                    _FieldLabel('Banner Title *'),
                    _InputField(
                      controller: _titleController,
                      hintText: 'Wholesale Summer Deals',
                      validator: (value) => _required(
                        value,
                        'Banner Title',
                      ),
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Subtitle'),
                    _InputField(
                      controller: _subtitleController,
                      hintText: 'Promote your supplier campaign',
                      maxLines: 2,
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Image URL'),
                    _InputField(
                      controller: _imageUrlController,
                      hintText: 'https://example.com/banner.png',
                      validator: _optionalUrl,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SectionCard(
                  title: 'Target Settings',
                  children: [
                    _FieldLabel('Target Type *'),
                    _TargetTypeDropdown(
                      value: _targetType,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _targetType = value;

                          if (_targetType == BannerTargetType.none) {
                            _targetValueController.clear();
                          }
                        });
                      },
                    ),
                    const _DividerSpace(),

                    _FieldLabel(
                      _targetValueRequired ? 'Target Value *' : 'Target Value',
                    ),
                    _InputField(
                      controller: _targetValueController,
                      hintText: _targetValueRequired
                          ? 'Product ID, Category ID, or URL'
                          : 'Not required',
                      enabled: _targetValueRequired,
                      validator: (value) {
                        if (!_targetValueRequired) return null;
                        return _required(value, 'Target Value');
                      },
                    ),
                    const _DividerSpace(),

                    _FieldLabel('Display Order *'),
                    _InputField(
                      controller: _displayOrderController,
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return _positiveInt(value, 'Display Order');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SectionCard(
                  title: 'Visibility',
                  children: [
                    _DateTimePickerRow(
                      label: 'Start Date',
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
                      label: 'End Date',
                      value: _formatDateTime(_endsAt),
                      onPick: () async {
                        final picked = await _pickDateTime(_endsAt);

                        if (picked == null) return;

                        setState(() {
                          _endsAt = picked;
                          _validateDates();
                        });
                      },
                      onClear: () {
                        setState(() {
                          _endsAt = null;
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

class _TargetTypeDropdown extends StatelessWidget {
  final BannerTargetType value;
  final ValueChanged<BannerTargetType?> onChanged;

  const _TargetTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<BannerTargetType>(
      value: value,
      items: BannerTargetType.values
          .map(
            (type) => DropdownMenuItem<BannerTargetType>(
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
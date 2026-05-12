import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../data/services/banner_image_upload_service.dart';
import '../../domain/entities/banner_entity.dart';
import '../bloc/banners_bloc.dart';
import '../bloc/banners_event.dart';
import '../bloc/banners_state.dart';

class CreateBannerScreen extends StatelessWidget {
  final BannerEntity? banner;

  const CreateBannerScreen({
    super.key,
    this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BannersBloc>(
      create: (_) => sl<BannersBloc>(),
      child: _CreateBannerView(banner: banner),
    );
  }
}

class _CreateBannerView extends StatefulWidget {
  final BannerEntity? banner;

  const _CreateBannerView({
    this.banner,
  });

  @override
  State<_CreateBannerView> createState() => _CreateBannerViewState();
}

class _CreateBannerViewState extends State<_CreateBannerView> {
  final _formKey = GlobalKey<FormState>();

  final ApiClient _apiClient = sl<ApiClient>(instanceName: 'projectApiClient');
  final BannerImageUploadService _imageUploadService =
      sl<BannerImageUploadService>();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _sortOrderController;

  final ImagePicker _imagePicker = ImagePicker();

  BannerTargetType _targetType = BannerTargetType.none;
  bool _active = true;

  DateTime? _startsAt;
  DateTime? _expiresAt;
  String? _dateError;

  bool _loadingTargets = false;
  bool _uploadingImage = false;
  String? _targetErrorMessage;

  final List<_BannerTargetOption> _targetOptions = [];
  String? _selectedTargetValue;
  String? _selectedTargetLabel;

  bool get _isEditMode => widget.banner != null;

  bool get _usesDropdownTarget {
    return _targetType == BannerTargetType.product ||
        _targetType == BannerTargetType.category ||
        _targetType == BannerTargetType.subcategory;
  }

  bool get _usesUrlTarget => _targetType == BannerTargetType.url;

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
    _sortOrderController = TextEditingController(
      text: banner?.sortOrder.toString() ?? '0',
    );

    _targetType = banner?.targetType ?? BannerTargetType.none;
    _selectedTargetValue = banner?.targetValue;
    _selectedTargetLabel = banner?.targetLabel;
    _active = banner?.active ?? true;
    _startsAt = banner?.startsAt;
    _expiresAt = banner?.expiresAt;

    _validateDates();

    if (_usesDropdownTarget) {
      _loadTargetOptions();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _targetValueController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploadingImage) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _uploadingImage = true;
      });

      final imageUrl = await _imageUploadService.uploadBannerImage(
        pickedFile.path,
      );

      if (!mounted) return;

      setState(() {
        _imageUrlController.text = imageUrl;
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banner image uploaded successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _loadTargetOptions() async {
    if (!_usesDropdownTarget) return;

    setState(() {
      _loadingTargets = true;
      _targetErrorMessage = null;
      _targetOptions.clear();
    });

    try {
      final path = switch (_targetType) {
        BannerTargetType.product => ApiConfig.supplierProducts,
        BannerTargetType.category => ApiConfig.supplierCategories,
        BannerTargetType.subcategory => ApiConfig.supplierSubCategories,
        BannerTargetType.url => '',
        BannerTargetType.none => '',
      };

      final response = await _apiClient.dio.get(path);
      final rawItems = _extractList(response.data);

      final options = rawItems
          .map((item) => _BannerTargetOption.fromJson(item, _targetType))
          .where((item) => item.id.trim().isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _targetOptions
          ..clear()
          ..addAll(options);

        if (_selectedTargetValue != null &&
            !_targetOptions.any((item) => item.id == _selectedTargetValue)) {
          _selectedTargetValue = null;
          _selectedTargetLabel = null;
        }

        _loadingTargets = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _targetErrorMessage = e.toString();
        _loadingTargets = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final possibleLists = [
        map['data'],
        map['items'],
        map['content'],
        map['products'],
        map['categories'],
        map['subcategories'],
        map['subCategories'],
      ];

      for (final item in possibleLists) {
        if (item is List) {
          return item
              .whereType<Map>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
        }
      }
    }

    return [];
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

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _targetValueValidator(String? value) {
    if (_targetType == BannerTargetType.none) return null;

    if (_usesDropdownTarget) {
      if (_selectedTargetValue == null || _selectedTargetValue!.isEmpty) {
        return 'Please select a ${_targetType.label.toLowerCase()}';
      }

      return null;
    }

    if (_usesUrlTarget) {
      if (value == null || value.trim().isEmpty) {
        return 'Target URL is required';
      }

      final text = value.trim();

      if (!text.startsWith('http://') && !text.startsWith('https://')) {
        return 'URL must start with http:// or https://';
      }
    }

    return null;
  }

  String? _sortOrderValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sort order is required';
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return 'Sort order must be a valid positive number';
    }

    return null;
  }

  Future<void> _handleTargetTypeChanged(BannerTargetType? value) async {
    if (value == null) return;

    setState(() {
      _targetType = value;
      _selectedTargetValue = null;
      _selectedTargetLabel = null;
      _targetValueController.clear();
      _targetOptions.clear();
      _targetErrorMessage = null;
    });

    if (_usesDropdownTarget) {
      await _loadTargetOptions();
    }
  }

  void _saveBanner(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateDates()) {
      setState(() {});
      return;
    }

    final targetValue = switch (_targetType) {
      BannerTargetType.none => null,
      BannerTargetType.url => _targetValueController.text.trim(),
      BannerTargetType.product ||
      BannerTargetType.category ||
      BannerTargetType.subcategory =>
        _selectedTargetValue,
    };

    final targetLabel = switch (_targetType) {
      BannerTargetType.none => null,
      BannerTargetType.url => _targetValueController.text.trim(),
      BannerTargetType.product ||
      BannerTargetType.category ||
      BannerTargetType.subcategory =>
        _selectedTargetLabel,
    };

    final banner = BannerEntity(
      id: widget.banner?.id ?? '',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      targetType: _targetType,
      targetValue: targetValue,
      targetLabel: targetLabel,
      sortOrder: int.parse(_sortOrderController.text.trim()),
      startsAt: _startsAt,
      expiresAt: _expiresAt,
      active: _active,
      createdAt: widget.banner?.createdAt,
      updatedAt: DateTime.now(),
    );

    if (_isEditMode) {
      context.read<BannersBloc>().add(UpdateBannerRequested(banner));
    } else {
      context.read<BannersBloc>().add(CreateBannerRequested(banner));
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
    final uploadedImageUrl = _imageUrlController.text.trim();

    return BlocListener<BannersBloc, BannersState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );

          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
              );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-banners');
          } else {
            context.go('/supplier-dashboard');
          }
        }
      },
      child: BlocBuilder<BannersBloc, BannersState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppThemeTokens.background,
            appBar: AppBar(
              backgroundColor: AppThemeTokens.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: state.saving || _uploadingImage ? null : _cancel,
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
                          onPressed: state.saving || _uploadingImage
                              ? null
                              : _cancel,
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
                          onPressed: state.saving || _uploadingImage
                              ? null
                              : () => _saveBanner(context),
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
                                      ? 'Update Banner'
                                      : 'Create Banner',
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
                          _FieldLabel('Title *'),
                          _InputField(
                            controller: _titleController,
                            hintText: 'Wholesale Deals',
                            validator: (value) {
                              return _required(value, 'Title');
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Subtitle'),
                          _InputField(
                            controller: _subtitleController,
                            hintText: 'Special offers for retailers',
                            maxLines: 2,
                          ),
                          const _DividerSpace(),
                          _FieldLabel('Banner Image *'),
                          _ImageUploadBox(
                            imageUrl: uploadedImageUrl,
                            uploading: _uploadingImage,
                            primary: primary,
                            onUpload: _pickAndUploadImage,
                          ),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: _imageUrlController,
                            hintText: 'Uploaded image URL will appear here',
                            validator: (value) {
                              return _required(value, 'Banner Image');
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload an image from your device. The backend returns a URL and stores it in the banner imageUrl field.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Target',
                        children: [
                          _FieldLabel('Target Type *'),
                          _TargetTypeDropdown(
                            value: _targetType,
                            onChanged: _handleTargetTypeChanged,
                          ),
                          if (_targetType != BannerTargetType.none) ...[
                            const _DividerSpace(),
                            if (_usesUrlTarget) ...[
                              _FieldLabel('Target URL *'),
                              _InputField(
                                controller: _targetValueController,
                                hintText: 'https://example.com',
                                validator: _targetValueValidator,
                              ),
                            ] else ...[
                              _FieldLabel('Select ${_targetType.label} *'),
                              if (_loadingTargets)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_targetErrorMessage != null)
                                _TargetErrorBox(
                                  message: _targetErrorMessage!,
                                  onRetry: _loadTargetOptions,
                                )
                              else
                                _TargetOptionDropdown(
                                  targetType: _targetType,
                                  value: _selectedTargetValue,
                                  options: _targetOptions,
                                  validator: (_) {
                                    return _targetValueValidator(
                                      _selectedTargetValue,
                                    );
                                  },
                                  onChanged: (value) {
                                    if (value == null) return;

                                    final selected = _targetOptions.firstWhere(
                                      (item) => item.id == value,
                                    );

                                    setState(() {
                                      _selectedTargetValue = selected.id;
                                      _selectedTargetLabel = selected.label;
                                    });
                                  },
                                ),
                              const SizedBox(height: 8),
                              const Text(
                                'The selected item name is shown here, but the backend saves its ID in targetValue.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeTokens.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: 'Display Rules',
                        children: [
                          _FieldLabel('Sort Order *'),
                          _InputField(
                            controller: _sortOrderController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _sortOrderValidator,
                          ),
                          const _DividerSpace(),
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

class _BannerTargetOption {
  final String id;
  final String label;

  const _BannerTargetOption({
    required this.id,
    required this.label,
  });

  factory _BannerTargetOption.fromJson(
    Map<String, dynamic> json,
    BannerTargetType targetType,
  ) {
    final id = _firstNonEmpty(json, [
      'id',
      'productId',
      'categoryId',
      'subCategoryId',
      'subcategoryId',
    ]);

    final name = _firstNonEmpty(json, [
      'name',
      'productName',
      'categoryName',
      'subCategoryName',
      'subcategoryName',
      'title',
    ]);

    final fallbackPrefix = switch (targetType) {
      BannerTargetType.product => 'Product',
      BannerTargetType.category => 'Category',
      BannerTargetType.subcategory => 'Subcategory',
      BannerTargetType.url => 'URL',
      BannerTargetType.none => 'Target',
    };

    return _BannerTargetOption(
      id: id,
      label: name.isEmpty ? '$fallbackPrefix #$id' : name,
    );
  }

  static String _firstNonEmpty(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}

class _ImageUploadBox extends StatelessWidget {
  final String imageUrl;
  final bool uploading;
  final Color primary;
  final VoidCallback onUpload;

  const _ImageUploadBox({
    required this.imageUrl,
    required this.uploading,
    required this.primary,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: uploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.broken_image_outlined,
                              color: primary,
                              size: 42,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        color: primary,
                        size: 42,
                      ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: uploading ? null : onUpload,
              icon: const Icon(Icons.upload_outlined),
              label: Text(
                uploading ? 'Uploading...' : 'Upload Image',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary.withOpacity(0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
      initialValue: value,
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

class _TargetOptionDropdown extends StatelessWidget {
  final BannerTargetType targetType;
  final String? value;
  final List<_BannerTargetOption> options;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _TargetOptionDropdown({
    required this.targetType,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value != null && options.any((item) => item.id == value)
        ? value
        : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.id,
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppThemeTokens.textPrimary,
      ),
      decoration: _dropdownDecoration(context).copyWith(
        hintText: 'Select ${targetType.label.toLowerCase()}',
      ),
    );
  }
}

class _TargetErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TargetErrorBox({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load target options',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
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
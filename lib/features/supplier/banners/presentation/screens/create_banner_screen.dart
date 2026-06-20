import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/utils/uploaded_image_url_resolver.dart';
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
    if (_targetType == BannerTargetType.url) {
      _targetType = BannerTargetType.none;
    }
    _selectedTargetValue = _targetType == BannerTargetType.none
        ? null
        : banner?.targetValue;
    _selectedTargetLabel = _targetType == BannerTargetType.none
        ? null
        : banner?.targetLabel;
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
        maxWidth: 1600,
        maxHeight: 1000,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      setState(() {
        _uploadingImage = true;
      });

      final imageUrl = UploadedImageUrlResolver.normalizeForBackend(
        await _imageUploadService.uploadBannerImage(
          pickedFile.path,
        ),
      );

      if (!mounted) return;

      setState(() {
        _imageUrlController.text = imageUrl;
        _uploadingImage = false;
      });

      AppToast.success(
        context,
        context.l10n.supplierBannerImageUploadedSuccessfully,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploadingImage = false;
      });

      AppToast.error(context, e);
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

  String _formatDateTime(BuildContext context, DateTime? date) {
    if (date == null) return '—';

    final locale = Localizations.localeOf(context).toLanguageTag();

    try {
      return DateFormat('MMM d, yyyy • h:mm a', locale).format(date);
    } catch (_) {
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      locale: Localizations.localeOf(context),
    );

    if (!mounted || pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
        !_startsAt!.isBefore(_expiresAt!)) {
      _dateError = context.l10n.supplierValidFromBeforeValidTo;
      return false;
    }

    _dateError = null;
    return true;
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.supplierFieldRequired(fieldName);
    }

    return null;
  }

  String? _targetValueValidator(String? value) {
    if (_targetType == BannerTargetType.none) return null;

    if (_usesDropdownTarget) {
      if (_selectedTargetValue == null || _selectedTargetValue!.isEmpty) {
        return context.l10n.supplierPleaseSelectTarget(
          _localizedOptionLabel(context, _targetType.label).toLowerCase(),
        );
      }

      return null;
    }

    if (_usesUrlTarget) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.supplierTargetUrlRequired;
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
      return context.l10n.supplierSortOrderRequired;
    }

    final parsed = int.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      return context.l10n.supplierSortOrderPositiveNumber;
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
    if (!_validateDates(requireBothDates: true)) {
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
      imageUrl: UploadedImageUrlResolver.normalizeForBackend(
        _imageUrlController.text,
      ),
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
      context.go('/supplier-banners');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final uploadedImageUrl = _imageUrlController.text.trim();

    return BlocListener<BannersBloc, BannersState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);

          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(
            context,
            localizeSupplierSuccessMessage(context, state.successMessage!),
          );

          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
              );

          if (_isEditMode) {
            context.go('/supplier-banners');
          } else {
            context.go('/supplier-banners');
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
                _isEditMode
                    ? context.l10n.supplierEditBanner
                    : context.l10n.supplierCreateBanner,
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
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _isEditMode
                                        ? context.l10n.supplierUpdateBanner
                                        : context.l10n.supplierCreateBanner,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                        title: context.l10n.supplierBannerInformation,
                        children: [
                          _FieldLabel(context.l10n.supplierTitle),
                          _InputField(
                            controller: _titleController,
                            hintText: context.l10n.supplierWholesaleDeals,
                            validator: (value) {
                              return _required(
                                value,
                                context.l10n.supplierTitlePlain,
                              );
                            },
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierSubtitle),
                          _InputField(
                            controller: _subtitleController,
                            hintText: context.l10n.supplierSpecialOffersForRetailers,
                            maxLines: 2,
                          ),
                          const _DividerSpace(),
                          _FieldLabel(context.l10n.supplierBannerImage2),
                          _ImageUploadBox(
                            imageUrl: uploadedImageUrl,
                            uploading: _uploadingImage,
                            primary: primary,
                            onUpload: _pickAndUploadImage,
                          ),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: _imageUrlController,
                            hintText:
                                context.l10n.supplierUploadedImageUrlWillAppearHere,
                            validator: (value) {
                              return _required(
                                value,
                                context.l10n.supplierBannerImagePlain,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.supplierUploadAnImageFromYourDeviceTheBackendReturnsAUrlAndStoresItInTheBannerImageurlField,
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
                        title: context.l10n.supplierTarget,
                        children: [
                          _FieldLabel(context.l10n.supplierTargetType),
                          _TargetTypeDropdown(
                            value: _targetType,
                            onChanged: _handleTargetTypeChanged,
                          ),
                          if (_targetType != BannerTargetType.none) ...[
                            const _DividerSpace(),
                            if (_usesUrlTarget) ...[
                              _FieldLabel(context.l10n.supplierTargetUrl),
                              _InputField(
                                controller: _targetValueController,
                                hintText: 'https://example.com',
                                validator: _targetValueValidator,
                              ),
                            ] else ...[
                              _FieldLabel('${context.l10n.supplierTarget} *'),
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
                              const SizedBox(height: 4),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: context.l10n.supplierDisplayRules,
                        children: [
                          _FieldLabel(context.l10n.supplierSortOrder),
                          _InputField(
                            controller: _sortOrderController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _sortOrderValidator,
                          ),
                          const _DividerSpace(),
                          _DateTimePickerRow(
                            label: context.l10n.supplierValidFrom,
                            value: _formatDateTime(context, _startsAt),
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
                            value: _formatDateTime(context, _expiresAt),
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
    final resolvedImageUrl = UploadedImageUrlResolver.resolve(imageUrl);
    final hasImage = resolvedImageUrl != null;

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
                          resolvedImageUrl,
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
                uploading ? context.l10n.uploadingLabel
                    : context.l10n.uploadImageButton,
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
  final int maxLines;
  final String? Function(String?)? validator;

  _InputField({
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
      borderRadius: BorderRadius.circular(14),
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
    final visibleTypes = BannerTargetType.values
        .where((type) => type != BannerTargetType.url)
        .toList();

    final safeValue = visibleTypes.contains(value)
        ? value
        : BannerTargetType.none;

    return DropdownButtonFormField<BannerTargetType>(
      value: safeValue,
      items: visibleTypes
          .map(
            (type) => DropdownMenuItem<BannerTargetType>(
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

class _TargetOptionDropdown extends StatefulWidget {
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
  State<_TargetOptionDropdown> createState() => _TargetOptionDropdownState();
}

class _TargetOptionDropdownState extends State<_TargetOptionDropdown> {
  Future<void> _openSearchSheet(BuildContext context) async {
    if (widget.options.isEmpty) return;

    final selected = await showModalBottomSheet<_BannerTargetOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TargetOptionSearchSheet(
          targetType: widget.targetType,
          options: widget.options,
          selectedValue: widget.value,
        );
      },
    );

    if (selected == null) return;

    widget.onChanged(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    _BannerTargetOption? safeOption;

    for (final option in widget.options) {
      if (option.id == widget.value) {
        safeOption = option;
        break;
      }
    }

    final hintText = context.l10n.supplierSelectTargetHint(
      _localizedOptionLabel(context, widget.targetType.label).toLowerCase(),
    );

    return FormField<String>(
      initialValue: safeOption?.id,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openSearchSheet(context),
              child: InputDecorator(
                isEmpty: safeOption == null,
                decoration: _dropdownDecoration(context).copyWith(
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down),
                ),
                child: Text(
                  safeOption?.label ?? hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: safeOption == null
                        ? AppThemeTokens.textSecondary
                        : AppThemeTokens.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TargetOptionSearchSheet extends StatefulWidget {
  final BannerTargetType targetType;
  final List<_BannerTargetOption> options;
  final String? selectedValue;

  const _TargetOptionSearchSheet({
    required this.targetType,
    required this.options,
    required this.selectedValue,
  });

  @override
  State<_TargetOptionSearchSheet> createState() =>
      _TargetOptionSearchSheetState();
}

class _TargetOptionSearchSheetState extends State<_TargetOptionSearchSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_BannerTargetOption> get _filteredOptions {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return widget.options;

    return widget.options
        .where((item) => item.label.toLowerCase().contains(query))
        .toList();
  }

  String _searchHint(BuildContext context) {
    return switch (widget.targetType) {
      BannerTargetType.product => context.l10n.searchProductsHint,
      BannerTargetType.category => context.l10n.searchCategoriesHint,
      BannerTargetType.subcategory => context.l10n.searchSubCategoriesHint,
      BannerTargetType.url => context.l10n.searchLabel,
      BannerTargetType.none => context.l10n.searchLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final filteredOptions = _filteredOptions;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeTokens.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.supplierSelectTargetLabel(
                  _localizedOptionLabel(context, widget.targetType.label),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: _dropdownDecoration(context).copyWith(
                  hintText: _searchHint(context),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredOptions.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.supplierNoResultsFound,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredOptions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppThemeTokens.border,
                        ),
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          final selected = option.id == widget.selectedValue;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppThemeTokens.textPrimary,
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
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
          Text(
            context.l10n.supplierCouldNotLoadTargetOptions,
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
            child: Text(
              context.l10n.retryButton,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
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
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
        color: AppThemeTokens.surface,
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
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeTokens.textPrimary,
                      side: const BorderSide(color: AppThemeTokens.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.clearButton,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.pickButton,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

String _localizedOptionLabel(BuildContext context, String label) {
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

String _localizedStatusLabel(BuildContext context, String label) {
  switch (label.toLowerCase()) {
    case 'active':
      return context.l10n.activeStatus;
    case 'inactive':
      return context.l10n.inactiveStatus;
    case 'scheduled':
      return context.l10n.supplierScheduled;
    case 'expired':
      return context.l10n.supplierExpired;
    case 'usage limit reached':
    case 'usage_limit_reached':
      return context.l10n.supplierUsageLimitReached;
    default:
      return label;
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/utils/app_error_mapper.dart';
import '../../../../../core/utils/picked_image_normalizer.dart';
import '../../../../../core/utils/uploaded_image_url_resolver.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../data/services/supplier_gallery_api_service.dart';
import '../../domain/entities/gallery_image_entity.dart';

/// Bottom sheet that lets a supplier reuse a picture already uploaded to
/// their gallery, or add a new one to it, instead of uploading the same
/// file again for every product/banner/logo.
///
/// Returns the picked image's URL, or null if the sheet was dismissed
/// without a selection.
Future<String?> showSupplierGalleryPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SupplierGalleryPickerSheet(),
  );
}

class _SupplierGalleryPickerSheet extends StatefulWidget {
  const _SupplierGalleryPickerSheet();

  @override
  State<_SupplierGalleryPickerSheet> createState() =>
      _SupplierGalleryPickerSheetState();
}

class _SupplierGalleryPickerSheetState
    extends State<_SupplierGalleryPickerSheet> {
  final _api = sl<SupplierGalleryApiService>();

  List<GalleryImageEntity> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final images = await _api.listImages();
      if (!mounted) return;

      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = AppErrorMapper.toMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadNewImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null || !mounted) return;

    final normalizedPath = await PickedImageNormalizer.toSrgb(
      pickedImage.path,
    );
    if (!mounted) return;

    setState(() => _isUploading = true);

    try {
      final uploaded = await _api.uploadImage(normalizedPath);
      if (!mounted) return;

      // Selecting the freshly uploaded image is what the supplier almost
      // always wants next, so close the sheet with it right away instead
      // of making them find it in the grid and tap it again.
      Navigator.of(context).pop(uploaded.imageUrl);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUploading = false);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeTokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.galleryTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppThemeTokens.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadImages,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _UploadTile(isUploading: _isUploading, onTap: _uploadNewImage);
        }

        final image = _images[index - 1];
        final resolvedUrl = UploadedImageUrlResolver.resolve(image.imageUrl);

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(image.imageUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: resolvedUrl == null
                ? Container(color: AppThemeTokens.background)
                : Image.network(
                    resolvedUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppThemeTokens.background,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _UploadTile extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadTile({required this.isUploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isUploading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeTokens.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Center(
          child: isUploading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

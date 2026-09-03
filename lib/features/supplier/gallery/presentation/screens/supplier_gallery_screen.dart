import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/utils/app_error_mapper.dart';
import '../../../../../core/utils/picked_image_normalizer.dart';
import '../../../../../core/utils/responsive_grid.dart';
import '../../../../../core/utils/uploaded_image_url_resolver.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/services/supplier_gallery_api_service.dart';
import '../../domain/entities/gallery_image_entity.dart';

/// Standalone screen listing every image a supplier has ever uploaded to
/// their gallery, with the ability to add more or remove ones no longer
/// needed. The same library backs the "Add from gallery" picker used on the
/// product, banner, and logo screens.
class SupplierGalleryScreen extends StatefulWidget {
  const SupplierGalleryScreen({super.key});

  @override
  State<SupplierGalleryScreen> createState() => _SupplierGalleryScreenState();
}

class _SupplierGalleryScreenState extends State<SupplierGalleryScreen> {
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

      setState(() {
        _images = [uploaded, ..._images];
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUploading = false);
      AppToast.error(context, e);
    }
  }

  Future<void> _confirmDelete(GalleryImageEntity image) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _galleryText(context, 'deleteImageTitle'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(_galleryText(context, 'deleteImageMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppThemeTokens.error),
              child: Text(
                context.l10n.deleteButton,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    // Removed from the grid right away — deleting from a library the
    // supplier is looking at should feel immediate, and a failure below
    // reloads the real state instead of leaving a stale optimistic one.
    setState(() {
      _images = _images.where((item) => item.id != image.id).toList();
    });

    try {
      await _api.deleteImage(image.id);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(context, e);
      _loadImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          _galleryText(context, 'title'),
          style: TextStyle(
            color: primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.refreshButton,
            onPressed: _isLoading ? null : _loadImages,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadImages,
          child: _buildBody(context, primary),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadNewImage,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_photo_alternate_outlined),
        label: Text(_galleryText(context, 'upload')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color primary) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppThemeTokens.surface,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 34),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppThemeTokens.textSecondary),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _loadImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.retryButton,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_images.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppThemeTokens.surface,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primary.withOpacity(0.12),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _galleryText(context, 'emptyTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _galleryText(context, 'emptyMessage'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.screenHorizontalPadding,
            16,
            AppThemeTokens.screenHorizontalPadding,
            96,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsiveGridColumns(
              constraints.maxWidth,
              targetCardWidth: 150,
            ),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            final image = _images[index];
            final resolvedUrl = UploadedImageUrlResolver.resolve(image.imageUrl);

            return Stack(
              children: [
                Positioned.fill(
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
                ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: _DeleteButton(onTap: () => _confirmDelete(image)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

String _galleryText(BuildContext context, String key) {
  final languageCode = Localizations.localeOf(context).languageCode;

  const en = {
    'title': 'Gallery',
    'upload': 'Upload',
    'emptyTitle': 'No images yet',
    'emptyMessage':
        'Images you upload here can be reused on products, banners, and your logo without uploading them again.',
    'deleteImageTitle': 'Delete image?',
    'deleteImageMessage':
        'This removes it from your gallery. Products or banners already using it keep their picture.',
  };

  const ar = {
    'title': 'معرض الصور',
    'upload': 'رفع صورة',
    'emptyTitle': 'لا توجد صور بعد',
    'emptyMessage':
        'الصور التي ترفعها هنا يمكن إعادة استخدامها في المنتجات والبانرات والشعار دون رفعها مجدداً.',
    'deleteImageTitle': 'حذف الصورة؟',
    'deleteImageMessage':
        'سيتم حذفها من المعرض. المنتجات أو البانرات التي تستخدمها حالياً تحتفظ بصورتها.',
  };

  const fr = {
    'title': 'Galerie',
    'upload': 'Ajouter',
    'emptyTitle': 'Aucune image pour le moment',
    'emptyMessage':
        'Les images ajoutées ici peuvent être réutilisées pour vos produits, bannières et logo sans les re-téléverser.',
    'deleteImageTitle': 'Supprimer l\'image ?',
    'deleteImageMessage':
        'Elle sera retirée de votre galerie. Les produits ou bannières qui l\'utilisent déjà gardent leur image.',
  };

  if (languageCode == 'ar') return ar[key] ?? key;
  if (languageCode == 'fr') return fr[key] ?? key;
  return en[key] ?? key;
}

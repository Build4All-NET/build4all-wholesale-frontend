import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/utils/uploaded_image_url_resolver.dart';
import '../../domain/entities/photographed_supplier_product_entity.dart';
import '../utils/supplier_excel_import_i18n.dart';

/// Photographing a catalogue into existence.
///
/// Two jobs, kept apart on purpose. Taking pictures is the first, and it is
/// deliberately just a button pressed once per thing on the shelf -- no
/// form, no questions. Everything the assistant made of them is the second,
/// below, where the supplier corrects a name and puts in the two things no
/// photograph can tell us: a price, and how many make a minimum order.
class SupplierExcelPhotoCaptureCard extends StatelessWidget {
  final List<PhotographedSupplierProductEntity> photos;
  final List<PhotographedSupplierProductEntity> needingName;
  final List<PhotographedSupplierProductEntity> needingDescription;
  final bool reading;
  final bool draftingDescriptions;

  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onDraftDescriptions;
  final void Function(int photoIndex, String name) onNameChanged;
  final void Function(int photoIndex, String category) onCategoryChanged;
  final void Function(int photoIndex, String price) onPriceChanged;
  final void Function(int photoIndex, String moq) onMoqChanged;
  final void Function(int photoIndex, String description) onDescriptionChanged;
  final void Function(int photoIndex) onRemove;

  const SupplierExcelPhotoCaptureCard({
    super.key,
    required this.photos,
    required this.needingName,
    required this.needingDescription,
    required this.reading,
    required this.draftingDescriptions,
    required this.onTakePhoto,
    required this.onPickFromGallery,
    required this.onDraftDescriptions,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onMoqChanged,
    required this.onDescriptionChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: reading ? null : onTakePhoto,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(photos.isEmpty ? l.photosTakeBtn : l.photosAddMoreBtn),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: reading ? null : onPickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(l.photosPickBtn),
              ),
            ),
          ],
        ),

        if (reading) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                l.photosReading,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],

        if (photos.isEmpty && !reading) ...[
          const SizedBox(height: 10),
          Text(
            l.photosEmpty,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],

        // The one thing that stands between the supplier and the button: a
        // product with no name cannot be created, and only they can supply
        // it.
        if (needingName.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l.photosNeedNames(needingName.length),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.error,
            ),
          ),
        ],

        // The assistant, offered here rather than after creation: this is
        // where the supplier is already deciding what each product says.
        if (needingDescription.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l.photosMissingDescriptions(needingDescription.length),
            style: const TextStyle(
              fontSize: 12.5,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: draftingDescriptions ? null : onDraftDescriptions,
            icon: draftingDescriptions
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.auto_awesome, size: 16, color: primary),
            label: Text(draftingDescriptions ? l.photosWriting : l.photosWriteDescriptions),
          ),
        ],

        for (final photo in photos) ...[
          const SizedBox(height: 10),
          _PhotoRow(
            key: ValueKey('photo-row-${photo.photoIndex}'),
            photo: photo,
            onNameChanged: (value) => onNameChanged(photo.photoIndex, value),
            onCategoryChanged: (value) => onCategoryChanged(photo.photoIndex, value),
            onPriceChanged: (value) => onPriceChanged(photo.photoIndex, value),
            onMoqChanged: (value) => onMoqChanged(photo.photoIndex, value),
            onDescriptionChanged: (value) =>
                onDescriptionChanged(photo.photoIndex, value),
            onRemove: () => onRemove(photo.photoIndex),
          ),
        ],
      ],
    );
  }
}

class _PhotoRow extends StatelessWidget {
  final PhotographedSupplierProductEntity photo;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onMoqChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onRemove;

  const _PhotoRow({
    super.key,
    required this.photo,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onMoqChanged,
    required this.onDescriptionChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final imageUrl = UploadedImageUrlResolver.resolve(photo.imageUrl);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: photo.needsName ? AppThemeTokens.error : AppThemeTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: imageUrl == null
                      ? Container(color: AppThemeTokens.background)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 20,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TextField(
                  key: ValueKey('photo-name-${photo.photoIndex}'),
                  label: l.photoNameLabel,
                  // What the assistant read, already in the field: correcting
                  // a word beats typing a name from nothing.
                  value: photo.name,
                  hint: photo.needsName ? l.photoNameMissing : null,
                  onChanged: onNameChanged,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                tooltip: l.photoRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TextField(
            key: ValueKey('photo-category-${photo.photoIndex}'),
            label: l.photoCategoryLabel,
            value: photo.category,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TextField(
                  key: ValueKey('photo-price-${photo.photoIndex}'),
                  label: l.photoPriceLabel,
                  value: photo.price,
                  numeric: true,
                  onChanged: onPriceChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TextField(
                  key: ValueKey('photo-moq-${photo.photoIndex}'),
                  label: l.photoMoqLabel,
                  value: photo.minimumOrderQuantity,
                  numeric: true,
                  onChanged: onMoqChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TextField(
            key: ValueKey('photo-description-${photo.photoIndex}'),
            label: l.headerLabel('description'),
            value: photo.description,
            lines: 2,
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String value;
  final bool numeric;
  final int lines;
  final ValueChanged<String> onChanged;

  const _TextField({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    this.numeric = false,
    this.lines = 1,
    required this.onChanged,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_TextField old) {
    super.didUpdateWidget(old);

    // The assistant writing into this row is the one time the field should
    // take a value it did not get from the person typing in it.
    if (widget.value != old.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // A controller, not initialValue: the field is rebuilt as the
      // supplier types, and rebuilding it from the value would send the
      // cursor back to the start.
      controller: _controller,
      keyboardType: widget.numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      minLines: widget.lines,
      maxLines: widget.lines,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        isDense: true,
        filled: true,
        fillColor: AppThemeTokens.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemeTokens.border),
        ),
      ),
    );
  }
}

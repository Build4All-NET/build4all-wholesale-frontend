import 'package:equatable/equatable.dart';

/// One product as it came off the camera: a gallery picture, what the
/// assistant made of it, and what the supplier has since decided about it.
///
/// Everything here except the price, the minimum order quantity, and (unless
/// the assistant wrote one) the description came from the photograph. The
/// name is a guess and the supplier's to correct; the picture is already
/// theirs, stored in their gallery the moment it was taken.
class PhotographedSupplierProductEntity extends Equatable {
  /// Which photograph this is in the batch, and how a correction finds its
  /// way back to the right one.
  final int photoIndex;

  final int? galleryImageId;
  final String? imageUrl;

  /// What the assistant thinks it is. Empty when it would not say, which is
  /// a product the supplier names themselves rather than one guessed at.
  final String name;

  final String category;
  final String price;
  final String minimumOrderQuantity;
  final String description;

  const PhotographedSupplierProductEntity({
    required this.photoIndex,
    required this.galleryImageId,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.price,
    required this.minimumOrderQuantity,
    required this.description,
  });

  bool get needsName => name.trim().isEmpty;
  bool get needsDescription => description.trim().isEmpty;

  PhotographedSupplierProductEntity copyWith({
    String? name,
    String? category,
    String? price,
    String? minimumOrderQuantity,
    String? description,
  }) {
    return PhotographedSupplierProductEntity(
      photoIndex: photoIndex,
      galleryImageId: galleryImageId,
      imageUrl: imageUrl,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        photoIndex,
        galleryImageId,
        imageUrl,
        name,
        category,
        price,
        minimumOrderQuantity,
        description,
      ];
}

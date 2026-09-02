class GalleryImageEntity {
  final String id;
  final String imageUrl;
  final String? originalFilename;

  const GalleryImageEntity({
    required this.id,
    required this.imageUrl,
    this.originalFilename,
  });

  factory GalleryImageEntity.fromJson(Map<String, dynamic> json) {
    return GalleryImageEntity(
      id: json['id'].toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      originalFilename: json['originalFilename']?.toString(),
    );
  }
}

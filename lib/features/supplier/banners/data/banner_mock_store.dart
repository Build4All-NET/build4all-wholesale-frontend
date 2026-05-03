import '../domain/entities/banner_entity.dart';

class BannerMockStore {
  BannerMockStore._();

  static final List<BannerEntity> _banners = [];

  static List<BannerEntity> get banners {
    final sorted = List<BannerEntity>.from(_banners);

    sorted.sort((a, b) {
      final orderCompare = a.displayOrder.compareTo(b.displayOrder);

      if (orderCompare != 0) return orderCompare;

      return b.id.compareTo(a.id);
    });

    return List.unmodifiable(sorted);
  }

  static void addBanner(BannerEntity banner) {
    _banners.insert(0, banner);
  }

  static void updateBanner(BannerEntity updatedBanner) {
    final index = _banners.indexWhere(
      (banner) => banner.id == updatedBanner.id,
    );

    if (index != -1) {
      _banners[index] = updatedBanner;
    }
  }

  static void deleteBanner(String id) {
    _banners.removeWhere((banner) => banner.id == id);
  }
}
import '../domain/entities/banner_entity.dart';

class BannerMockStore {
  static final List<BannerEntity> _banners = [];

  static List<BannerEntity> get banners {
    final sorted = List<BannerEntity>.from(_banners);

    sorted.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);

      if (orderCompare != 0) {
        return orderCompare;
      }

      return a.title.compareTo(b.title);
    });

    return List.unmodifiable(sorted);
  }

  static void addBanner(BannerEntity banner) {
    _banners.add(banner);
  }

  static void updateBanner(BannerEntity banner) {
    final index = _banners.indexWhere((item) => item.id == banner.id);

    if (index == -1) {
      _banners.add(banner);
      return;
    }

    _banners[index] = banner;
  }

  static void deleteBanner(String id) {
    _banners.removeWhere((banner) => banner.id == id);
  }

  static BannerEntity? findById(String id) {
    try {
      return _banners.firstWhere((banner) => banner.id == id);
    } catch (_) {
      return null;
    }
  }

  static void clear() {
    _banners.clear();
  }
}
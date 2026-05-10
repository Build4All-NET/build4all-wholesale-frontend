import '../entities/banner_entity.dart';

abstract class BannerRepository {
  Future<List<BannerEntity>> getBanners();

  Future<BannerEntity> createBanner(BannerEntity banner);

  Future<BannerEntity> updateBanner(BannerEntity banner);

  Future<void> deleteBanner(String bannerId);
}
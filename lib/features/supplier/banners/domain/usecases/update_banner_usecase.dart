import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class UpdateBannerUseCase {
  final BannerRepository repository;

  UpdateBannerUseCase(this.repository);

  Future<BannerEntity> call(BannerEntity banner) {
    return repository.updateBanner(banner);
  }
}
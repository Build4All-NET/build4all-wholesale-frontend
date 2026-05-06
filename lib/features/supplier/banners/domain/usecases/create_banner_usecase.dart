import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class CreateBannerUseCase {
  final BannerRepository repository;

  CreateBannerUseCase(this.repository);

  Future<BannerEntity> call(BannerEntity banner) {
    return repository.createBanner(banner);
  }
}
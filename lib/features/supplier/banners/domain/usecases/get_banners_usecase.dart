import '../entities/banner_entity.dart';
import '../repositories/banner_repository.dart';

class GetBannersUseCase {
  final BannerRepository repository;

  GetBannersUseCase(this.repository);

  Future<List<BannerEntity>> call() {
    return repository.getBanners();
  }
}
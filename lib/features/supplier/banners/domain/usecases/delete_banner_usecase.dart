import '../repositories/banner_repository.dart';

class DeleteBannerUseCase {
  final BannerRepository repository;

  DeleteBannerUseCase(this.repository);

  Future<void> call(String bannerId) {
    return repository.deleteBanner(bannerId);
  }
}
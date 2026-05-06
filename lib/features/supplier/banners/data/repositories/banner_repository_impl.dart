import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import '../models/banner_model.dart';
import '../services/banner_api_service.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerApiService apiService;

  BannerRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<BannerEntity>> getBanners() async {
    final models = await apiService.getBanners();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<BannerEntity> createBanner(BannerEntity banner) async {
    final model = BannerModel.fromEntity(banner);
    final created = await apiService.createBanner(model);

    return created.toEntity();
  }

  @override
  Future<BannerEntity> updateBanner(BannerEntity banner) async {
    final model = BannerModel.fromEntity(banner);
    final updated = await apiService.updateBanner(model);

    return updated.toEntity();
  }

  @override
  Future<void> deleteBanner(String bannerId) {
    return apiService.deleteBanner(bannerId);
  }
}
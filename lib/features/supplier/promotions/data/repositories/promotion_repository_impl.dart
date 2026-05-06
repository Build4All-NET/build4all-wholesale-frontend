import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../models/promotion_model.dart';
import '../services/promotion_api_service.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionApiService apiService;

  PromotionRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<PromotionEntity>> getPromotions() async {
    final models = await apiService.getPromotions();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PromotionEntity> createPromotion(
    PromotionEntity promotion,
  ) async {
    final model = PromotionModel.fromEntity(promotion);
    final created = await apiService.createPromotion(model);

    return created.toEntity();
  }

  @override
  Future<PromotionEntity> updatePromotion(
    PromotionEntity promotion,
  ) async {
    final model = PromotionModel.fromEntity(promotion);
    final updated = await apiService.updatePromotion(model);

    return updated.toEntity();
  }

  @override
  Future<void> deletePromotion(String promotionId) {
    return apiService.deletePromotion(promotionId);
  }
}
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class UpdatePromotionUseCase {
  final PromotionRepository repository;

  UpdatePromotionUseCase(this.repository);

  Future<PromotionEntity> call(PromotionEntity promotion) {
    return repository.updatePromotion(promotion);
  }
}
import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<List<PromotionEntity>> getPromotions();

  Future<PromotionEntity> createPromotion(PromotionEntity promotion);

  Future<PromotionEntity> updatePromotion(PromotionEntity promotion);

  Future<void> deletePromotion(String promotionId);
}
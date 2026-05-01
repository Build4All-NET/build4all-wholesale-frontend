import '../domain/entities/promotion_entity.dart';

class PromotionMockStore {
  PromotionMockStore._();

  static final List<PromotionEntity> _promotions = [];

  static List<PromotionEntity> get promotions => List.unmodifiable(_promotions);

  static void addPromotion(PromotionEntity promotion) {
    _promotions.add(promotion);
  }

  static void updatePromotion(PromotionEntity updatedPromotion) {
    final index = _promotions.indexWhere(
      (promotion) => promotion.id == updatedPromotion.id,
    );

    if (index != -1) {
      _promotions[index] = updatedPromotion;
    }
  }

  static void deletePromotion(String id) {
    _promotions.removeWhere((promotion) => promotion.id == id);
  }
}
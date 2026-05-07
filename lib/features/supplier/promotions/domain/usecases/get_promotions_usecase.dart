import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetPromotionsUseCase {
  final PromotionRepository repository;

  GetPromotionsUseCase(this.repository);

  Future<List<PromotionEntity>> call() {
    return repository.getPromotions();
  }
}
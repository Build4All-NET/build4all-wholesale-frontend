import '../domain/entities/promotion_entity.dart';

class PromotionMockData {
  static const List<PromotionEntity> promotions = [
    PromotionEntity(
      id: '1',
      title: 'No promotions yet',
      description: 'Create your first promotion to show it to retailers.',
      discountLabel: '0%',
      status: 'Draft',
      startDate: '-',
      endDate: '-',
    ),
  ];
}
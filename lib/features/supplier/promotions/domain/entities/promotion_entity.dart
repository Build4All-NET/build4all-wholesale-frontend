class PromotionEntity {
  final String id;
  final String title;
  final String description;
  final String discountLabel;
  final String status;
  final String startDate;
  final String endDate;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountLabel,
    required this.status,
    required this.startDate,
    required this.endDate,
  });
}
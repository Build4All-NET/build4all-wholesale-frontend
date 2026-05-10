import 'package:equatable/equatable.dart';

import '../../domain/entities/promotion_entity.dart';

abstract class PromotionsEvent extends Equatable {
  const PromotionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPromotionsRequested extends PromotionsEvent {
  const LoadPromotionsRequested();
}

class CreatePromotionRequested extends PromotionsEvent {
  final PromotionEntity promotion;

  const CreatePromotionRequested(this.promotion);

  @override
  List<Object?> get props => [promotion];
}

class UpdatePromotionRequested extends PromotionsEvent {
  final PromotionEntity promotion;

  const UpdatePromotionRequested(this.promotion);

  @override
  List<Object?> get props => [promotion];
}

class DeletePromotionRequested extends PromotionsEvent {
  final String promotionId;

  const DeletePromotionRequested(this.promotionId);

  @override
  List<Object?> get props => [promotionId];
}

class ClearPromotionMessageRequested extends PromotionsEvent {
  const ClearPromotionMessageRequested();
}
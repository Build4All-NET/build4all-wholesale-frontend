import 'package:equatable/equatable.dart';

import '../../domain/entities/coupon_entity.dart';

abstract class CouponsEvent extends Equatable {
  const CouponsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCouponsRequested extends CouponsEvent {
  const LoadCouponsRequested();
}

class CreateCouponRequested extends CouponsEvent {
  final CouponEntity coupon;

  const CreateCouponRequested(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

class UpdateCouponRequested extends CouponsEvent {
  final CouponEntity coupon;

  const UpdateCouponRequested(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

class DeleteCouponRequested extends CouponsEvent {
  final String couponId;

  const DeleteCouponRequested(this.couponId);

  @override
  List<Object?> get props => [couponId];
}

class ClearCouponMessageRequested extends CouponsEvent {
  const ClearCouponMessageRequested();
}
import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class CreateCouponUseCase {
  final CouponRepository repository;

  CreateCouponUseCase(this.repository);

  Future<CouponEntity> call(CouponEntity coupon) {
    return repository.createCoupon(coupon);
  }
}
import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class UpdateCouponUseCase {
  final CouponRepository repository;

  UpdateCouponUseCase(this.repository);

  Future<CouponEntity> call(CouponEntity coupon) {
    return repository.updateCoupon(coupon);
  }
}
import '../entities/coupon_entity.dart';
import '../repositories/coupon_repository.dart';

class GetCouponsUseCase {
  final CouponRepository repository;

  GetCouponsUseCase(this.repository);

  Future<List<CouponEntity>> call() {
    return repository.getCoupons();
  }
}
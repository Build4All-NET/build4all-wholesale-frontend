import '../entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<List<CouponEntity>> getCoupons();

  Future<CouponEntity> createCoupon(CouponEntity coupon);

  Future<CouponEntity> updateCoupon(CouponEntity coupon);

  Future<void> deleteCoupon(String couponId);
}
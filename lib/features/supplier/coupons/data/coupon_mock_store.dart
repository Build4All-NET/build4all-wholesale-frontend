import '../domain/entities/coupon_entity.dart';

class CouponMockStore {
  CouponMockStore._();

  static final List<CouponEntity> _coupons = [];

  static List<CouponEntity> get coupons => List.unmodifiable(_coupons);

  static void addCoupon(CouponEntity coupon) {
    _coupons.insert(0, coupon);
  }

  static void updateCoupon(CouponEntity updatedCoupon) {
    final index = _coupons.indexWhere(
      (coupon) => coupon.id == updatedCoupon.id,
    );

    if (index != -1) {
      _coupons[index] = updatedCoupon;
    }
  }

  static void deleteCoupon(String id) {
    _coupons.removeWhere((coupon) => coupon.id == id);
  }
}
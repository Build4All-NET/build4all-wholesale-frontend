import '../domain/entities/coupon_entity.dart';

class CouponMockStore {
  static final List<CouponEntity> _coupons = [];

  static List<CouponEntity> get coupons {
    return List.unmodifiable(_coupons);
  }

  static void addCoupon(CouponEntity coupon) {
    _coupons.insert(0, coupon);
  }

  static void updateCoupon(CouponEntity coupon) {
    final index = _coupons.indexWhere((item) => item.id == coupon.id);

    if (index == -1) {
      _coupons.insert(0, coupon);
      return;
    }

    _coupons[index] = coupon;
  }

  static void deleteCoupon(String id) {
    _coupons.removeWhere((coupon) => coupon.id == id);
  }

  static bool codeExists({
    required String code,
    String? exceptCouponId,
  }) {
    final normalizedCode = code.trim().toUpperCase();

    return _coupons.any((coupon) {
      if (exceptCouponId != null && coupon.id == exceptCouponId) {
        return false;
      }

      return coupon.code.trim().toUpperCase() == normalizedCode;
    });
  }
}
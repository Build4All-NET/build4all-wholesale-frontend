import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../models/coupon_model.dart';
import '../services/coupon_api_service.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponApiService apiService;

  CouponRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<CouponEntity>> getCoupons() async {
    final models = await apiService.getCoupons();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CouponEntity> createCoupon(CouponEntity coupon) async {
    final model = CouponModel.fromEntity(coupon);
    final created = await apiService.createCoupon(model);

    return created.toEntity();
  }

  @override
  Future<CouponEntity> updateCoupon(CouponEntity coupon) async {
    final model = CouponModel.fromEntity(coupon);
    final updated = await apiService.updateCoupon(model);

    return updated.toEntity();
  }

  @override
  Future<void> deleteCoupon(String couponId) {
    return apiService.deleteCoupon(couponId);
  }
}
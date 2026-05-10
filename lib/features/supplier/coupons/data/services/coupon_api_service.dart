import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/coupon_model.dart';

class CouponApiService {
  final ApiClient apiClient;

  CouponApiService(this.apiClient);

  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await apiClient.dio.get(ApiConfig.supplierCoupons);
      final data = response.data;

      if (data is List) {
        return data
            .map(
              (item) => CouponModel.fromBackendJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<CouponModel> createCoupon(CouponModel coupon) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierCoupons,
        data: coupon.toBackendCreateJson(),
      );

      return CouponModel.fromBackendJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<CouponModel> updateCoupon(CouponModel coupon) async {
    try {
      final response = await apiClient.dio.put(
        ApiConfig.supplierCouponById(coupon.id),
        data: coupon.toBackendCreateJson(),
      );

      return CouponModel.fromBackendJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      await apiClient.dio.delete(
        ApiConfig.supplierCouponById(couponId),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    return e.message ?? 'Something went wrong';
  }
}
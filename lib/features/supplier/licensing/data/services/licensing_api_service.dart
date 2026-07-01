import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../models/available_payment_method_model.dart';
import '../models/owner_app_access_response.dart';
import '../models/upgrade_payment_confirmation_model.dart';
import '../models/upgrade_payment_intent_model.dart';
import '../models/upgrade_plan_model.dart';
import '../models/upgrade_request_model.dart';

/// Gateway for the build4all licensing / subscription endpoints.
///
/// Uses the CENTRAL build4all client (`centralApiClient`) because licensing is
/// owned by the control plane. The client's interceptor injects the bearer
/// token and transparently refreshes it, so this service stays thin.
///
/// The tenant is inferred from the JWT, so all calls target the `.../apps/me/*`
/// routes — no explicit project id is sent.
class LicensingApiService {
  final ApiClient centralApiClient;

  LicensingApiService(this.centralApiClient);

  Dio get _dio => centralApiClient.dio;

  Future<OwnerAppAccessResponse> getCurrentLicensePlan() async {
    try {
      final res = await _dio.get('/licensing/apps/me/access');
      return OwnerAppAccessResponse.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<List<UpgradePlanModel>> getAvailableUpgradePlans() async {
    try {
      final res = await _dio.get('/licensing/apps/me/upgrade-plans');
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map && data['plans'] is List ? data['plans'] as List : const []);
      return list
          .whereType<Map>()
          .map((e) => UpgradePlanModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<List<AvailablePaymentMethodModel>> getAvailablePaymentMethods() async {
    try {
      final res = await _dio.get('/licensing/apps/me/payment-methods');
      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) =>
                AvailablePaymentMethodModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<UpgradePaymentIntentModel> initiateUpgradePayment({
    required String planCode,
    required String billingCycle,
    required String paymentMethodCode,
    int? usersAllowedOverride,
  }) async {
    try {
      final res = await _dio.post(
        '/licensing/apps/me/upgrade/payment-intent',
        data: {
          'planCode': planCode,
          'billingCycle': billingCycle,
          'paymentMethodCode': paymentMethodCode,
          'usersAllowedOverride': usersAllowedOverride,
        },
      );
      return UpgradePaymentIntentModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<UpgradePaymentConfirmationModel> confirmUpgradePayment({
    required String paymentIntentId,
  }) async {
    try {
      final res = await _dio.post(
        '/licensing/apps/me/upgrade/payment-confirm',
        data: {'paymentIntentId': paymentIntentId},
      );
      return UpgradePaymentConfirmationModel.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<void> requestUpgradeMe({
    required String planCode,
    int? usersAllowedOverride,
    String? billingCycle,
  }) async {
    try {
      await _dio.post(
        '/licensing/apps/me/upgrade-request',
        data: {
          'planCode': planCode,
          'usersAllowedOverride': usersAllowedOverride,
          if (billingCycle != null) 'billingCycle': billingCycle,
        },
      );
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  Future<List<UpgradeRequestModel>> listUpgradeRequests() async {
    try {
      final res = await _dio.get('/licensing/apps/me/upgrade-requests');
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map && data['requests'] is List
              ? data['requests'] as List
              : const []);
      return list
          .whereType<Map>()
          .map((e) => UpgradeRequestModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw AppException(_msg(e));
    }
  }

  String _msg(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return e.message ?? 'Something went wrong';
  }
}

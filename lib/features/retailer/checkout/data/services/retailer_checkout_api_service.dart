import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../models/retailer_checkout_model.dart';
import '../models/retailer_split_checkout_model.dart';

class RetailerCheckoutApiService {
  final ApiClient apiClient;

  RetailerCheckoutApiService(this.apiClient);

  Future<List<RetailerEligibleCheckoutBranchModel>>
  getEligibleBranches() async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerCheckoutEligibleBranches,
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => RetailerEligibleCheckoutBranchModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutPreviewModel> previewCheckout({
    required RetailerCheckoutPreviewRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerCheckoutPreview,
        data: request.toJson(),
      );

      return RetailerCheckoutPreviewModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutOrderModel> createOrder({
    required RetailerCreateCheckoutOrderRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerOrders,
        data: request.toJson(),
      );

      return RetailerCheckoutOrderModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutPaymentStartModel> startPayment({
    required int orderId,
    required RetailerStartPaymentRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerOrderPaymentStart(orderId),
        data: request.toJson(),
      );

      return RetailerCheckoutPaymentStartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }


  Future<RetailerCheckoutPaymentStartModel> confirmStripePayment({
    required int orderId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerOrderStripeConfirm(orderId),
      );

      return RetailerCheckoutPaymentStartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutPaymentStartModel> confirmMpgsPayment({
    required int orderId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerOrderMpgsConfirm(orderId),
      );

      return RetailerCheckoutPaymentStartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutPaymentStartModel> confirmPaypalPayment({
    required int orderId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerOrderPaypalConfirm(orderId),
      );

      return RetailerCheckoutPaymentStartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerCheckoutPaymentStartModel> getPaymentStatus({
    required int orderId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerOrderPaymentStatus(orderId),
      );

      return RetailerCheckoutPaymentStartModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }



  Future<RetailerSplitCheckoutPreviewModel> splitPreviewCheckout({
    required RetailerSplitCheckoutPreviewRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerSplitCheckoutPreview,
        data: request.toJson(),
      );

      return RetailerSplitCheckoutPreviewModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerSplitCheckoutPlaceModel> splitPlaceCheckout({
    required RetailerSplitCheckoutPlaceRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerSplitCheckoutPlace,
        data: request.toJson(),
      );

      return RetailerSplitCheckoutPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerSplitCheckoutPlaceModel> startSplitSessionPayment({
    required int sessionId,
    required RetailerStartPaymentRequestModel request,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerSplitCheckoutSessionPaymentStart(sessionId),
        data: request.toJson(),
      );

      return RetailerSplitCheckoutPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerSplitCheckoutPlaceModel> confirmSplitStripePayment({
    required int sessionId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerSplitCheckoutSessionStripeConfirm(sessionId),
      );

      return RetailerSplitCheckoutPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerSplitCheckoutPlaceModel> confirmSplitMpgsPayment({
    required int sessionId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.retailerSplitCheckoutSessionMpgsConfirm(sessionId),
      );

      return RetailerSplitCheckoutPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Future<RetailerSplitCheckoutPlaceModel> getSplitSessionPaymentStatus({
    required int sessionId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConfig.retailerSplitCheckoutSessionPaymentStatus(sessionId),
      );

      return RetailerSplitCheckoutPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
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

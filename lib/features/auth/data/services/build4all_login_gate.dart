import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/login_account_type.dart';

class Build4AllLoginGateResult {
  final bool supplierCanLogin;
  final bool retailerCanLogin;

  const Build4AllLoginGateResult({
    required this.supplierCanLogin,
    required this.retailerCanLogin,
  });

  bool get hasNoAccount => !supplierCanLogin && !retailerCanLogin;
  bool get hasOnlySupplier => supplierCanLogin && !retailerCanLogin;
  bool get hasOnlyRetailer => !supplierCanLogin && retailerCanLogin;
  bool get hasBoth => supplierCanLogin && retailerCanLogin;

  LoginAccountType? get singleType {
    if (hasOnlySupplier) return LoginAccountType.supplier;
    if (hasOnlyRetailer) return LoginAccountType.retailer;
    return null;
  }
}

class Build4AllLoginGate {
  Build4AllLoginGate()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<Build4AllLoginGateResult> checkAvailableAccounts({
    required String email,
    required String password,
  }) async {
    final supplierResult = await _canSupplierLogin(
      email: email,
      password: password,
    );

    final retailerResult = await _canRetailerLogin(
      email: email,
      password: password,
    );

    debugPrint(
      'LOGIN GATE RESULT => supplier=$supplierResult retailer=$retailerResult',
    );

    return Build4AllLoginGateResult(
      supplierCanLogin: supplierResult,
      retailerCanLogin: retailerResult,
    );
  }

  Future<bool> _canRetailerLogin({
    required String email,
    required String password,
  }) async {
    final ownerProjectLinkId = int.tryParse(AppConfig.ownerProjectLinkId);

    if (ownerProjectLinkId == null) {
      debugPrint('LOGIN GATE retailer skipped: invalid ownerProjectLinkId');
      return false;
    }

    return _canLogin(
      label: 'retailer',
      endpoint: ApiConfig.userLogin,
      data: {
        'email': email.trim(),
        'password': password,
        'ownerProjectLinkId': ownerProjectLinkId,
      },
    );
  }

  Future<bool> _canSupplierLogin({
    required String email,
    required String password,
  }) async {
    final ownerProjectId = int.tryParse(AppConfig.ownerProjectLinkId);

    if (ownerProjectId == null) {
      debugPrint('LOGIN GATE supplier skipped: invalid ownerProjectId');
      return false;
    }

    return _canLogin(
      label: 'supplier',
      endpoint: ApiConfig.adminLoginFront,
      data: {
        'usernameOrEmail': email.trim(),
        'password': password,
        'ownerProjectId': ownerProjectId,
      },
    );
  }

  Future<bool> _canLogin({
    required String label,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('LOGIN GATE TRY $label endpoint=$endpoint data=$data');

      final response = await _dio.post(endpoint, data: data);

      final statusCode = response.statusCode ?? 0;

      if (statusCode < 200 || statusCode >= 300) {
        debugPrint('LOGIN GATE $label rejected: status=$statusCode');
        return false;
      }

      final body = response.data;

      if (body is Map<String, dynamic>) {
        final wasDeleted = body['wasDeleted'] == true;
        if (wasDeleted) return false;

        final success = body['success'];
        if (success == false) return false;

        final message = body['message']?.toString().toLowerCase() ?? '';

        if (message.contains('invalid') ||
            message.contains('wrong') ||
            message.contains('incorrect') ||
            message.contains('bad credentials') ||
            message.contains('not found') ||
            message.contains('failed')) {
          debugPrint('LOGIN GATE $label rejected message=$message');
          return false;
        }

        final token =
            body['token'] ??
            body['accessToken'] ??
            body['access_token'] ??
            body['jwt'];

        if (token != null && token.toString().trim().isNotEmpty) {
          return true;
        }

        if (body['user'] != null) return true;
        if (body['admin'] != null) return true;
        if (body['data'] != null) return true;
        if (success == true) return true;
      }

      return true;
    } on DioException catch (e) {
      debugPrint(
        'LOGIN GATE FAILED $label endpoint=$endpoint '
        'status=${e.response?.statusCode} '
        'data=${e.response?.data}',
      );

      return false;
    } catch (e) {
      debugPrint('LOGIN GATE ERROR $label endpoint=$endpoint error=$e');
      return false;
    }
  }
}

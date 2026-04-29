import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  final Dio dio;
  final AuthStorage authStorage;

  ApiClient(this.authStorage, {required String baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 60),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          final isPublicCentralAuth =
              path == '/auth/admin/login/front' ||
              path == '/auth/user/login' ||
              path == '/auth/send-verification' ||
              path == '/auth/verify-email-code' ||
              path == '/auth/complete-profile';

          if (!isPublicCentralAuth) {
            final token = await authStorage.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // DEBUG LOGS
          print(
            'API REQUEST: ${options.method} ${options.baseUrl}${options.path}',
          );
          print('API HEADERS: ${options.headers}');
          print('API QUERY: ${options.queryParameters}');
          print('API BODY: ${options.data}');

          handler.next(options);
        },

        onResponse: (response, handler) {
          // DEBUG LOGS
          print(
            'API RESPONSE: ${response.requestOptions.method} '
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          print('STATUS CODE: ${response.statusCode}');
          print('RESPONSE DATA: ${response.data}');

          handler.next(response);
        },

        onError: (error, handler) {
          // DEBUG LOGS
          print(
            'API ERROR: ${error.requestOptions.method} '
            '${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          print('ERROR TYPE: ${error.type}');
          print('ERROR MESSAGE: ${error.message}');
          print('ERROR STATUS CODE: ${error.response?.statusCode}');
          print('ERROR RESPONSE DATA: ${error.response?.data}');

          handler.next(error);
        },
      ),
    );
  }
}
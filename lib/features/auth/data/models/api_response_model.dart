import '../../domain/entities/api_response_entity.dart';

class ApiResponseModel extends ApiResponseEntity {
  const ApiResponseModel({
    required super.success,
    required super.message,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

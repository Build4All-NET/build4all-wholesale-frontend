import '../../domain/entities/supplier_profile_display_entity.dart';

class SupplierProfileDisplayModel extends SupplierProfileDisplayEntity {
  const SupplierProfileDisplayModel({
    super.adminId,
    super.username,
    super.firstName,
    super.lastName,
    super.email,
    super.phoneNumber,
    super.role,
    super.businessId,
    super.notifyItemUpdates,
    super.notifyUserFeedback,
    super.createdAt,
    super.updatedAt,
  });

  factory SupplierProfileDisplayModel.fromJson(Map<String, dynamic> json) {
    return SupplierProfileDisplayModel(
      adminId: _toInt(json['adminId'] ?? json['id']),
      username: _toStringValue(json['username']),
      firstName: _toStringValue(json['firstName']),
      lastName: _toStringValue(json['lastName']),
      email: _toStringValue(json['email']),
      phoneNumber: _toStringValue(
        json['phoneNumber'] ?? json['phone'] ?? json['mobileNumber'],
      ),
      role: _toStringValue(json['role']),
      businessId: _toInt(json['businessId']),
      notifyItemUpdates: _toBool(json['notifyItemUpdates']),
      notifyUserFeedback: _toBool(json['notifyUserFeedback']),
      createdAt: _toStringValue(json['createdAt']),
      updatedAt: _toStringValue(json['updatedAt']),
    );
  }

  static String? _toStringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final text = value.toString().toLowerCase().trim();
    if (text == 'true') return true;
    if (text == 'false') return false;

    return null;
  }
}

import '../../domain/entities/supplier_retailer_entity.dart';

class SupplierRetailerModel extends SupplierRetailerEntity {
  const SupplierRetailerModel({
    required super.id,
    required super.build4allUserId,
    required super.name,
    required super.username,
    required super.email,
    required super.phoneNumber,
    required super.storeName,
    required super.city,
    required super.countryName,
    required super.businessType,
    required super.createdAt,
    required super.lastLoginAt,
  });

  factory SupplierRetailerModel.fromJson(Map<String, dynamic> json) {
    return SupplierRetailerModel(
      id: _int(json['id']),
      build4allUserId: _int(json['build4allUserId']),
      name: _str(json['name']),
      username: _str(json['username']),
      email: _str(json['email']),
      phoneNumber: _str(json['phoneNumber']),
      storeName: _str(json['storeName']),
      city: _str(json['city']),
      countryName: _str(json['countryName']),
      businessType: _str(json['businessType']),
      createdAt: _date(json['createdAt']),
      lastLoginAt: _date(json['lastLoginAt']),
    );
  }

  static int _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  static DateTime? _date(dynamic v) {
    final s = v?.toString().trim() ?? '';
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}

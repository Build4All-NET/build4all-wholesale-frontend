import '../../domain/entities/branch_entity.dart';

class BranchModel extends BranchEntity {
  final int totalProducts;
  final int totalStock;

  const BranchModel({
    required super.id,
    required super.name,
    required super.city,
    required super.address,
    required super.phoneNumber,
    required super.status,
    this.totalProducts = 0,
    this.totalStock = 0,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      status: _statusFromJson(json['status']),
      totalProducts: int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0,
      totalStock: int.tryParse(json['totalStock']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'phoneNumber': phoneNumber,
      'status': _statusToJson(status),
      'totalProducts': totalProducts,
      'totalStock': totalStock,
    };
  }

  static BranchStatus _statusFromJson(dynamic value) {
    final status = value?.toString().toUpperCase();

    if (status == 'INACTIVE') {
      return BranchStatus.inactive;
    }

    return BranchStatus.active;
  }

  static String _statusToJson(BranchStatus status) {
    switch (status) {
      case BranchStatus.active:
        return 'ACTIVE';
      case BranchStatus.inactive:
        return 'INACTIVE';
    }
  }
}
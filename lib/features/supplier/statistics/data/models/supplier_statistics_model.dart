import '../../domain/entities/supplier_statistics_entity.dart';

import 'supplier_retailer_model.dart';

class SupplierStatisticsModel extends SupplierStatisticsEntity {
  const SupplierStatisticsModel({
    required super.totalRetailers,
    required super.reachableRetailers,
    required super.withEmail,
    required super.withPhone,
    required super.withCompleteProfile,
    required super.newRetailersLast7Days,
    required super.newRetailersLast30Days,
    required super.activeLast30Days,
    required super.retailers,
  });

  factory SupplierStatisticsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['retailers'];

    final retailers = raw is List
        ? raw
            .whereType<Map>()
            .map(
              (e) => SupplierRetailerModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : <SupplierRetailerModel>[];

    return SupplierStatisticsModel(
      totalRetailers: _int(json['totalRetailers'], fallback: retailers.length),
      reachableRetailers: _int(json['reachableRetailers']),
      withEmail: _int(json['withEmail']),
      withPhone: _int(json['withPhone']),
      withCompleteProfile: _int(json['withCompleteProfile']),
      newRetailersLast7Days: _int(json['newRetailersLast7Days']),
      newRetailersLast30Days: _int(json['newRetailersLast30Days']),
      activeLast30Days: _int(json['activeLast30Days']),
      retailers: retailers,
    );
  }

  static int _int(dynamic v, {int fallback = 0}) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }
}

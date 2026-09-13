import 'supplier_retailer_entity.dart';

/// The supplier's view of their app's audience: a few headline counts and the
/// retailers those counts describe.
///
/// The counts come from the server rather than being recomputed here, so the
/// tiles and the list below them always agree.
class SupplierStatisticsEntity {
  final int totalRetailers;
  final int reachableRetailers;
  final int withEmail;
  final int withPhone;
  final int withCompleteProfile;
  final int newRetailersLast7Days;
  final int newRetailersLast30Days;
  final int activeLast30Days;
  final List<SupplierRetailerEntity> retailers;

  const SupplierStatisticsEntity({
    required this.totalRetailers,
    required this.reachableRetailers,
    required this.withEmail,
    required this.withPhone,
    required this.withCompleteProfile,
    required this.newRetailersLast7Days,
    required this.newRetailersLast30Days,
    required this.activeLast30Days,
    required this.retailers,
  });

  static const empty = SupplierStatisticsEntity(
    totalRetailers: 0,
    reachableRetailers: 0,
    withEmail: 0,
    withPhone: 0,
    withCompleteProfile: 0,
    newRetailersLast7Days: 0,
    newRetailersLast30Days: 0,
    activeLast30Days: 0,
    retailers: <SupplierRetailerEntity>[],
  );

  bool get isEmpty => retailers.isEmpty;

  /// Retailers the supplier can actually reach, as a 0..1 fraction.
  double get reachableRate {
    if (totalRetailers <= 0) return 0;
    return (reachableRetailers / totalRetailers).clamp(0, 1).toDouble();
  }

  /// Case-insensitive search over the fields a supplier would type: name,
  /// shop, email, phone, city.
  List<SupplierRetailerEntity> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return retailers;

    return retailers.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.storeName.toLowerCase().contains(q) ||
          r.username.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          r.phoneNumber.toLowerCase().contains(q) ||
          r.city.toLowerCase().contains(q);
    }).toList();
  }
}

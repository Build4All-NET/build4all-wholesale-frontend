enum BranchStatus {
  active,
  inactive,
}

class BranchEntity {
  final String id;
  final String name;
  final String countryCode;
  final String countryName;
  final int? regionId;
  final String regionName;
  final String city;
  final String address;
  final String phoneNumber;
  final BranchStatus status;

  BranchEntity({
    required this.id,
    required this.name,
    this.countryCode = '',
    this.countryName = '',
    this.regionId,
    this.regionName = '',
    required this.city,
    required this.address,
    required this.phoneNumber,
    required this.status,
  });

  String get locationLabel {
    final parts = [
      city.trim(),
      regionName.trim(),
      countryName.trim(),
    ].where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) return city;

    return parts.join(', ');
  }
}

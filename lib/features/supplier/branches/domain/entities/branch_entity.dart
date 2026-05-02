enum BranchStatus {
  active,
  inactive,
}

class BranchEntity {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phoneNumber;
  final BranchStatus status;

  const BranchEntity({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phoneNumber,
    required this.status,
  });
}
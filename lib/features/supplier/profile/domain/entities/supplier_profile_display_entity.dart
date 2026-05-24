class SupplierProfileDisplayEntity {
  final int? adminId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final int? businessId;
  final bool? notifyItemUpdates;
  final bool? notifyUserFeedback;
  final String? createdAt;
  final String? updatedAt;

  SupplierProfileDisplayEntity({
    this.adminId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.businessId,
    this.notifyItemUpdates,
    this.notifyUserFeedback,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final value = '$first $last'.trim();

    if (value.isNotEmpty) return value;
    if ((username ?? '').trim().isNotEmpty) return username!.trim();
    if ((email ?? '').trim().isNotEmpty) return email!.trim();

    return 'Supplier';
  }

  String get displayRole {
    final value = role?.trim();
    if (value == null || value.isEmpty) return 'Not provided';
    return value;
  }
}

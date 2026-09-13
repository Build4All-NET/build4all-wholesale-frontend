/// One retailer who installed the supplier's app, as the statistics screen
/// shows them: who they are, their shop, and how to reach them.
class SupplierRetailerEntity {
  final int id;
  final int build4allUserId;
  final String name;
  final String username;
  final String email;
  final String phoneNumber;
  final String storeName;
  final String city;
  final String countryName;
  final String businessType;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const SupplierRetailerEntity({
    required this.id,
    required this.build4allUserId,
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.storeName,
    required this.city,
    required this.countryName,
    required this.businessType,
    required this.createdAt,
    required this.lastLoginAt,
  });

  bool get hasEmail => email.trim().isNotEmpty;

  bool get hasPhone => phoneNumber.trim().isNotEmpty;

  /// False when there is nothing to tap — the card then says so instead of
  /// opening a popup with no actions in it.
  bool get canBeContacted => hasEmail || hasPhone;

  /// Falls back through the shop name and username so a row never renders
  /// blank, even for a retailer who signed up before the identity columns
  /// existed and has not logged in since.
  String get displayName {
    final n = name.trim();
    if (n.isNotEmpty) return n;

    final s = storeName.trim();
    if (s.isNotEmpty) return s;

    final u = username.trim();
    if (u.isNotEmpty) return u;

    final e = email.trim();
    if (e.isNotEmpty) return e;

    return '#$id';
  }

  /// Where the shop is, as one line, skipping whatever is missing.
  String get location {
    return [city.trim(), countryName.trim()]
        .where((part) => part.isNotEmpty)
        .join(', ');
  }

  /// First letter of the display name, for the avatar placeholder.
  String get initial {
    final source = displayName.trim();
    if (source.isEmpty) return '?';
    return source.substring(0, 1).toUpperCase();
  }
}

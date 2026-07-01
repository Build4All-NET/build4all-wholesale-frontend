class AvailablePaymentMethod {
  final int id;
  final String code; // type code — e.g. STRIPE / CASH
  final String typeName;
  final String displayName;
  final String? providerCode;

  const AvailablePaymentMethod({
    required this.id,
    required this.code,
    required this.typeName,
    required this.displayName,
    this.providerCode,
  });

  /// The code sent to the backend when the owner chooses this method.
  /// Prefer providerCode (more specific) if present, otherwise type code.
  String get selectionCode =>
      (providerCode != null && providerCode!.isNotEmpty) ? providerCode! : code;

  bool get isStripe => code.toUpperCase() == 'STRIPE';
  bool get isPaypal => code.toUpperCase() == 'PAYPAL';
  bool get isMpgs => code.toUpperCase() == 'MPGS';
}

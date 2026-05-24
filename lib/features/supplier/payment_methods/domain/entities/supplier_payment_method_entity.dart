class SupplierPaymentMethodEntity {
  final int? id;
  final String code;
  final String displayName;
  final bool platformEnabled;
  final bool projectEnabled;
  final bool supportedNow;
  final bool requiresCredentials;
  final String helperText;
  final Map<String, dynamic> configSchema;
  final Map<String, dynamic> configValues;
  final DateTime? updatedAt;

  const SupplierPaymentMethodEntity({
    required this.id,
    required this.code,
    required this.displayName,
    required this.platformEnabled,
    required this.projectEnabled,
    required this.supportedNow,
    required this.requiresCredentials,
    required this.helperText,
    required this.configSchema,
    required this.configValues,
    required this.updatedAt,
  });

  bool get isCash => code.toUpperCase() == 'CASH';
}

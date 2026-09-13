/// What one column of a file the platform did not produce can turn out to be.
///
/// Mirrors the server's own list. Two differences from the ecommerce importer,
/// both from this domain: a wholesale product has no SKU, and it does have a
/// minimum order quantity.
enum SupplierForeignField {
  name,
  price,
  stock,
  moq,
  description,
  category,
  imageUrl,
  ignore;

  /// The wire name the server reads and writes.
  String get wireName {
    switch (this) {
      case SupplierForeignField.name:
        return 'NAME';
      case SupplierForeignField.price:
        return 'PRICE';
      case SupplierForeignField.stock:
        return 'STOCK';
      case SupplierForeignField.moq:
        return 'MOQ';
      case SupplierForeignField.description:
        return 'DESCRIPTION';
      case SupplierForeignField.category:
        return 'CATEGORY';
      case SupplierForeignField.imageUrl:
        return 'IMAGE_URL';
      case SupplierForeignField.ignore:
        return 'IGNORE';
    }
  }

  /// A field name this app does not know reads as "not imported", which is what
  /// a column nobody claimed already means.
  static SupplierForeignField fromWire(String? raw) {
    final value = (raw ?? '').trim().toUpperCase();
    for (final field in SupplierForeignField.values) {
      if (field.wireName == value) return field;
    }
    return SupplierForeignField.ignore;
  }
}

/// Why a column was read the way it was.
///
/// Sent as a code rather than a sentence so the supplier reads it in their own
/// language instead of the server's.
enum SupplierForeignGuessReason {
  agreed,
  fromValues,
  fromHeading,
  fromAssistant,
  disputed,
  noMatch;

  static SupplierForeignGuessReason fromWire(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'AGREED':
        return SupplierForeignGuessReason.agreed;
      case 'FROM_VALUES':
        return SupplierForeignGuessReason.fromValues;
      case 'FROM_HEADING':
        return SupplierForeignGuessReason.fromHeading;
      case 'FROM_ASSISTANT':
        return SupplierForeignGuessReason.fromAssistant;
      case 'DISPUTED':
        return SupplierForeignGuessReason.disputed;
      default:
        return SupplierForeignGuessReason.noMatch;
    }
  }
}

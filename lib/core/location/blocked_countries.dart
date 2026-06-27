/// Countries that must never be offered anywhere in the app (country pickers,
/// phone-number country dropdowns, etc.). Matching is done by ISO code and by
/// name to be robust against either field being used.
class BlockedCountries {
  const BlockedCountries._();

  /// ISO 3166-1 alpha-2 / alpha-3 codes of blocked countries.
  static const Set<String> isoCodes = {'IL', 'ISR'};

  /// Lower-cased name fragments of blocked countries.
  static const Set<String> nameKeywords = {'israel'};

  static bool isBlockedIso(String? iso) {
    if (iso == null) return false;
    return isoCodes.contains(iso.trim().toUpperCase());
  }

  static bool isBlockedName(String? name) {
    if (name == null) return false;
    final lower = name.trim().toLowerCase();
    return nameKeywords.any(lower.contains);
  }

  /// True if any of the provided identifiers belongs to a blocked country.
  static bool isBlocked({String? iso2, String? iso3, String? name}) {
    return isBlockedIso(iso2) || isBlockedIso(iso3) || isBlockedName(name);
  }
}

class LocationHintHelper {
  const LocationHintHelper._();

  static String cityAreaHint({
    String? countryIso2,
    String? regionName,
    String? genericHint,
    String? leBeirutHint,
    String? leMountHint,
    String? leNorthHint,
    String? leSouthHint,
    String? leBekaaHint,
    String? leGenericHint,
  }) {
    final country = countryIso2?.toUpperCase().trim();
    final region = regionName?.toLowerCase().trim() ?? '';

    if (country == 'LB') {
      if (region.contains('beirut')) {
        return leBeirutHint ?? 'e.g., Hamra, Achrafieh, Verdun';
      }
      if (region.contains('mount')) {
        return leMountHint ?? 'e.g., Baabda, Jounieh, Aley';
      }
      if (region.contains('north') || region.contains('akkar')) {
        return leNorthHint ?? 'e.g., Tripoli, Batroun, Halba';
      }
      if (region.contains('south') || region.contains('nabatieh')) {
        return leSouthHint ?? 'e.g., Saida, Tyre, Nabatieh';
      }
      if (region.contains('bekaa') || region.contains('baalbek')) {
        return leBekaaHint ?? 'e.g., Zahle, Baalbek, Chtaura';
      }
      return leGenericHint ?? 'e.g., Beirut, Tripoli, Saida';
    }

    return genericHint ?? 'e.g., city, district, or business area';
  }
}

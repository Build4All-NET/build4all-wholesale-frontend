class LocationHintHelper {
  const LocationHintHelper._();

  static String cityAreaHint({
    String? countryIso2,
    String? regionName,
  }) {
    final country = countryIso2?.toUpperCase().trim();
    final region = regionName?.toLowerCase().trim() ?? '';

    if (country == 'LB') {
      if (region.contains('beirut')) return 'e.g., Hamra, Achrafieh, Verdun';
      if (region.contains('mount')) return 'e.g., Baabda, Jounieh, Aley';
      if (region.contains('north') || region.contains('akkar')) {
        return 'e.g., Tripoli, Batroun, Halba';
      }
      if (region.contains('south') || region.contains('nabatieh')) {
        return 'e.g., Saida, Tyre, Nabatieh';
      }
      if (region.contains('bekaa') || region.contains('baalbek')) {
        return 'e.g., Zahle, Baalbek, Chtaura';
      }
      return 'e.g., Beirut, Tripoli, Saida';
    }

    if (country == 'AE') {
      if (region.contains('dubai')) {
        return 'e.g., Dubai Marina, Business Bay, Deira';
      }
      if (region.contains('abu')) {
        return 'e.g., Khalifa City, Mussafah, Al Reem Island';
      }
      if (region.contains('sharjah')) return 'e.g., Al Majaz, Al Nahda, Muwaileh';
      return 'e.g., Dubai Marina, Business Bay, Al Nahda';
    }

    if (country == 'SA') {
      if (region.contains('riyadh')) return 'e.g., Olaya, Al Malaz, Al Yasmin';
      if (region.contains('makkah') || region.contains('mecca')) {
        return 'e.g., Jeddah, Makkah, Taif';
      }
      if (region.contains('eastern')) return 'e.g., Dammam, Khobar, Dhahran';
      return 'e.g., Riyadh, Jeddah, Dammam';
    }

    if (country == 'QA') return 'e.g., West Bay, Al Sadd, The Pearl';
    if (country == 'KW') return 'e.g., Salmiya, Hawalli, Kuwait City';
    if (country == 'JO') return 'e.g., Abdali, Sweifieh, Zarqa';
    if (country == 'EG') return 'e.g., Nasr City, Maadi, Alexandria';
    if (country == 'TR') return 'e.g., Kadikoy, Besiktas, Cankaya';
    if (country == 'FR') return 'e.g., Paris 15e, Lyon Centre, Marseille';
    if (country == 'US') return 'e.g., Downtown, Brooklyn, Santa Monica';

    return 'e.g., city, district, or business area';
  }
}

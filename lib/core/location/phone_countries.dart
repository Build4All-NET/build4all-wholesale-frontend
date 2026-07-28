import 'package:intl_phone_field/countries.dart';

import 'blocked_countries.dart';

/// The intl_phone_field country list with blocked countries (Israel) removed,
/// so the phone-number country-code dropdown never offers them — neither by
/// ISO code, by name, nor by dial code.
final List<Country> allowedPhoneCountries = countries
    .where((country) =>
        !BlockedCountries.isBlocked(iso2: country.code, name: country.name) &&
        country.dialCode != '972')
    .toList();

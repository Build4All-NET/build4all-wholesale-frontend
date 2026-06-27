import 'package:intl_phone_field/countries.dart';

/// The intl_phone_field country list with blocked countries (Israel) removed,
/// so the phone-number country-code dropdown never offers them.
final List<Country> allowedPhoneCountries = countries
    .where((country) =>
        country.code.toUpperCase() != 'IL' && country.dialCode != '972')
    .toList();

import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Shared phone-number rules for every phone input in the app.
///
/// The rules mirror the e-commerce app:
///  * Lebanese mobiles written on the old `03` prefix are only 7 digits long
///    (`3` + 6 digits), so they must be accepted next to the regular 8-digit
///    numbers.
///  * The national prefix `0` is stripped from Lebanese numbers before they
///    are stored, so `03 123 456` and `3 123 456` produce the same
///    `+9613123456`.
///
/// The `intl_phone_field` package applies its own length check (Lebanon is
/// declared as exactly 8 digits) and that check silently overrides any custom
/// validator, so every field using these helpers must also set
/// `disableLengthCheck: true`.
class PhoneValidation {
  const PhoneValidation._();

  static const String lebanonIso = 'LB';

  /// Digits only, with a single leading national prefix `0` removed.
  static String normalizeLocalDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('0')) {
      return digits.substring(1);
    }

    return digits;
  }

  /// Lebanese numbers, once the leading `0` is dropped:
  ///  * numbers starting with `3` are exactly 7 digits (`3123456`),
  ///  * every other number keeps the previous rule (7 or 8 digits, e.g.
  ///    `70123456` mobiles and `1350000` landlines).
  ///
  /// The leading `0` is ignored, so `03123456` and `3123456` are both valid.
  static bool isValidLebaneseNumber(String rawLocalNumber) {
    final digits = normalizeLocalDigits(rawLocalNumber);

    if (digits.isEmpty) return false;

    // Mobile numbers on the old "03" prefix are 7 digits long.
    if (digits.startsWith('3')) {
      return digits.length == 7;
    }

    return digits.length == 7 || digits.length == 8;
  }

  /// Validates the local (national) part of a number against the selected
  /// country. Lebanon uses the rules above; every other country keeps the
  /// length range declared by `intl_phone_field`, which is what the package
  /// used to enforce on its own before the length check was disabled.
  static bool isValidNumberForCountry({
    required String isoCode,
    required String rawLocalNumber,
  }) {
    final iso = isoCode.trim().toUpperCase();

    if (iso == lebanonIso) {
      return isValidLebaneseNumber(rawLocalNumber);
    }

    final digits = rawLocalNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;

    final country = _countryForIso(iso);

    if (country == null) {
      return digits.length >= 6 && digits.length <= 15;
    }

    return digits.length >= country.minLength &&
        digits.length <= country.maxLength;
  }

  /// The E.164 number to store for [phone], or an empty string when nothing
  /// has been typed. Lebanese numbers are normalized (`03…` -> `+9613…`);
  /// other countries keep the number exactly as the package built it, since
  /// some of them keep their trunk prefix in the international format.
  static String completeNumberFor(PhoneNumber phone) {
    if (phone.number.trim().isEmpty) return '';

    if (phone.countryISOCode.trim().toUpperCase() == lebanonIso) {
      final digits = normalizeLocalDigits(phone.number);
      if (digits.isEmpty) return '';

      return '${_withPlus(phone.countryCode)}$digits';
    }

    return _withPlus(phone.completeNumber);
  }

  /// Adds the missing `+` to a number that already carries its country code
  /// (`PhoneNumber.fromCompleteNumber` drops it).
  static String ensureLeadingPlus(String number) {
    final trimmed = number.trim();
    if (trimmed.isEmpty) return '';

    return _withPlus(trimmed);
  }

  static Country? _countryForIso(String iso) {
    for (final country in countries) {
      if (country.code.toUpperCase() == iso) return country;
    }

    return null;
  }

  static String _withPlus(String value) {
    var text = value.trim().replaceAll(' ', '');

    if (text.startsWith('00')) {
      text = text.substring(2);
    }

    return text.startsWith('+') ? text : '+$text';
  }
}

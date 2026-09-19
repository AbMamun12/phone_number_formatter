import '../data/countries_data.dart';
import '../models/country_phone_info.dart';
import '../models/phone_number_result.dart';
import '../validator/phone_number_validator.dart';

/// Parses raw phone number strings into structured results, E.164, and formatted representations.
class PhoneNumberParser {
  /// Parses a phone number input string.
  ///
  /// If [defaultCountry] is omitted, it defaults to Bangladesh or auto-detection.
  static PhoneNumberResult parse(
    String input, {
    CountryPhoneInfo? defaultCountry,
  }) {
    final cleanDigits = input.replaceAll(RegExp(r'\D'), '');
    final country = CountriesData.detectCountry(
      input,
      fallback: defaultCountry ?? CountriesData.defaultCountry,
    );

    if (country == null) {
      return PhoneNumberResult(
        rawInput: input,
        cleanDigits: cleanDigits,
        nationalDigits: cleanDigits,
        isValid: false,
        errorMessage: 'Unable to detect country for the phone number',
      );
    }

    final validation = PhoneNumberValidator.validate(input, country: country);

    // Extract national digits without dial code
    String nationalDigits = cleanDigits;
    final dialDigits = country.dialDigits;

    if (input.trim().startsWith('+') && nationalDigits.startsWith(dialDigits)) {
      nationalDigits = nationalDigits.substring(dialDigits.length);
    } else if (nationalDigits.startsWith(dialDigits) &&
        nationalDigits.length > country.maxLength) {
      nationalDigits = nationalDigits.substring(dialDigits.length);
    }

    // Determine digits with and without trunk prefix ('0')
    final trunk = country.trunkPrefix;
    String digitsWithoutTrunk = nationalDigits;
    if (trunk != null && trunk.isNotEmpty && digitsWithoutTrunk.startsWith(trunk)) {
      digitsWithoutTrunk = digitsWithoutTrunk.substring(trunk.length);
    }

    String localNationalDigits = nationalDigits;
    if (trunk != null && trunk.isNotEmpty && !localNationalDigits.startsWith(trunk)) {
      localNationalDigits = '$trunk$localNationalDigits';
    }

    // Standardize formatted representations
    String formattedNational;
    String formattedInternational;
    String e164;

    if (country.isoCode == 'BD') {
      // Bangladesh formatting
      formattedNational = country.applyMask(localNationalDigits);
      formattedInternational = '+880 ${country.applyMask(digitsWithoutTrunk, maskOverride: '####-######')}';
      e164 = '+880$digitsWithoutTrunk';
    } else {
      // Universal country formatting
      formattedNational = country.applyMask(localNationalDigits);
      final intlMask = country.internationalMask;
      if (intlMask != null && intlMask.contains(country.dialCode)) {
        formattedInternational = '${country.dialCode} ${country.applyMask(digitsWithoutTrunk, maskOverride: country.dialCodeNumberMask)}';
      } else {
        formattedInternational = '${country.dialCode} ${country.applyMask(digitsWithoutTrunk, maskOverride: country.dialCodeNumberMask)}';
      }
      e164 = '${country.dialCode}$digitsWithoutTrunk';
    }

    return PhoneNumberResult(
      rawInput: input,
      cleanDigits: cleanDigits,
      country: country,
      nationalDigits: nationalDigits,
      e164: e164,
      international: formattedInternational,
      national: formattedNational,
      isValid: validation.isValid,
      errorMessage: validation.errorMessage,
    );
  }
}

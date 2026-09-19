import '../data/countries_data.dart';
import '../models/country_phone_info.dart';

/// Result details of phone number validation.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int currentDigitCount;
  final int? expectedMinDigits;
  final int? expectedMaxDigits;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.currentDigitCount,
    this.expectedMinDigits,
    this.expectedMaxDigits,
  });

  const ValidationResult.valid({required int digitCount})
      : isValid = true,
        errorMessage = null,
        currentDigitCount = digitCount,
        expectedMinDigits = null,
        expectedMaxDigits = null;

  const ValidationResult.invalid({
    required this.errorMessage,
    required int digitCount,
    this.expectedMinDigits,
    this.expectedMaxDigits,
  })  : isValid = false,
        currentDigitCount = digitCount;

  @override
  String toString() => isValid ? 'Valid ($currentDigitCount digits)' : 'Invalid: $errorMessage';
}

/// Phone number validator with country-specific rules, including Bangladesh 11-digit enforcement.
class PhoneNumberValidator {
  /// Validates a phone number against country rules or auto-detected country.
  ///
  /// [strictPrefix] defaults to false to prevent rejecting updated or new operator allocations.
  static ValidationResult validate(
    String input, {
    CountryPhoneInfo? country,
    bool strictPrefix = false,
  }) {
    final cleanDigits = input.replaceAll(RegExp(r'\D'), '');

    if (cleanDigits.isEmpty) {
      return const ValidationResult.invalid(
        errorMessage: 'Phone number cannot be empty',
        digitCount: 0,
      );
    }

    final targetCountry = country ?? CountriesData.detectCountry(input);
    if (targetCountry == null) {
      return ValidationResult.invalid(
        errorMessage: 'Unknown country code',
        digitCount: cleanDigits.length,
      );
    }

    // Specialize for Bangladesh condition
    if (targetCountry.isoCode == 'BD') {
      return _validateBangladesh(input, cleanDigits, strictPrefix: strictPrefix);
    }

    // Specialize for United States / Canada
    if (targetCountry.isoCode == 'US' || targetCountry.isoCode == 'CA') {
      return _validateNorthAmerica(cleanDigits, targetCountry);
    }

    // Specialize for India
    if (targetCountry.isoCode == 'IN') {
      return _validateIndia(cleanDigits, targetCountry, strictPrefix: strictPrefix);
    }

    // Standard country validation
    return _validateGeneric(cleanDigits, targetCountry, strictPrefix);
  }

  /// Specialized validation for Bangladesh:
  /// - Without trunk prefix (accompanying dial code +880): exactly 10 digits starting with 1 (e.g. 1712345678 or 1234534564).
  /// - With trunk prefix (national standalone): exactly 11 digits starting with 01 (e.g. 01712345678 or 01234534564).
  static ValidationResult _validateBangladesh(
    String rawInput,
    String cleanDigits, {
    bool strictPrefix = false,
  }) {
    String nationalDigits = cleanDigits;

    // Handle when country code 880 is present in rawInput or cleanDigits
    if (rawInput.contains('+880') || cleanDigits.startsWith('880')) {
      if (cleanDigits.startsWith('880')) {
        nationalDigits = cleanDigits.substring(3);
      }
      // If user typed +880 01..., strip leading 0
      if (nationalDigits.startsWith('0')) {
        nationalDigits = nationalDigits.substring(1);
      }
    }

    // Case A: 10-digit format without trunk prefix (starts with 1)
    if (nationalDigits.startsWith('1')) {
      if (nationalDigits.length < 10) {
        return ValidationResult.invalid(
          errorMessage: 'Bangladesh number requires 10 digits after +880 (current: ${nationalDigits.length})',
          digitCount: nationalDigits.length,
          expectedMinDigits: 10,
          expectedMaxDigits: 10,
        );
      }
      if (nationalDigits.length > 10) {
        return ValidationResult.invalid(
          errorMessage: 'Bangladesh phone number cannot exceed 10 digits after +880 (current: ${nationalDigits.length})',
          digitCount: nationalDigits.length,
          expectedMinDigits: 10,
          expectedMaxDigits: 10,
        );
      }

      if (strictPrefix) {
        final validIntlPrefixes = ['13', '14', '15', '16', '17', '18', '19'];
        if (!validIntlPrefixes.any((p) => nationalDigits.startsWith(p))) {
          return ValidationResult.invalid(
            errorMessage: 'Invalid Bangladesh operator code. Must start with 13, 14, 15, 16, 17, 18, or 19',
            digitCount: nationalDigits.length,
          );
        }
      }

      return ValidationResult.valid(digitCount: 10);
    }

    // Case B: 11-digit national local format (starts with 01)
    if (nationalDigits.startsWith('0')) {
      if (nationalDigits.length < 11) {
        return ValidationResult.invalid(
          errorMessage: 'Bangladesh phone number must be exactly 11 digits (current: ${nationalDigits.length})',
          digitCount: nationalDigits.length,
          expectedMinDigits: 11,
          expectedMaxDigits: 11,
        );
      }
      if (nationalDigits.length > 11) {
        return ValidationResult.invalid(
          errorMessage: 'Bangladesh phone number cannot exceed 11 digits (current: ${nationalDigits.length})',
          digitCount: nationalDigits.length,
          expectedMinDigits: 11,
          expectedMaxDigits: 11,
        );
      }

      if (!nationalDigits.startsWith('01')) {
        return ValidationResult.invalid(
          errorMessage: "Bangladesh national phone number must begin with '01'",
          digitCount: nationalDigits.length,
        );
      }

      if (strictPrefix) {
        final validOpPrefixes = ['013', '014', '015', '016', '017', '018', '019'];
        if (!validOpPrefixes.any((p) => nationalDigits.startsWith(p))) {
          return ValidationResult.invalid(
            errorMessage: 'Invalid operator code. Valid prefixes are 013, 014, 015, 016, 017, 018, 019',
            digitCount: nationalDigits.length,
          );
        }
      }

      return ValidationResult.valid(digitCount: 11);
    }

    return ValidationResult.invalid(
      errorMessage: "Bangladesh phone number must start with '1' (after +880) or '01' (national)",
      digitCount: nationalDigits.length,
    );
  }

  /// North America validation (US, CA): 10 digits
  static ValidationResult _validateNorthAmerica(String cleanDigits, CountryPhoneInfo country) {
    String digits = cleanDigits;
    if (digits.startsWith('1') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) {
      return ValidationResult.invalid(
        errorMessage: '${country.name} phone number must be exactly 10 digits (current: ${digits.length})',
        digitCount: digits.length,
        expectedMinDigits: 10,
        expectedMaxDigits: 10,
      );
    }

    // First digit of area code and exchange code cannot be 0 or 1
    if (digits.startsWith('0') || digits.startsWith('1')) {
      return ValidationResult.invalid(
        errorMessage: 'Area code cannot start with 0 or 1',
        digitCount: digits.length,
      );
    }

    return ValidationResult.valid(digitCount: 10);
  }

  /// India validation: 10 digits
  static ValidationResult _validateIndia(
    String cleanDigits,
    CountryPhoneInfo country, {
    bool strictPrefix = false,
  }) {
    String digits = cleanDigits;
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) {
      return ValidationResult.invalid(
        errorMessage: 'India mobile number must be exactly 10 digits (current: ${digits.length})',
        digitCount: digits.length,
        expectedMinDigits: 10,
        expectedMaxDigits: 10,
      );
    }

    if (strictPrefix && !['6', '7', '8', '9'].contains(digits[0])) {
      return ValidationResult.invalid(
        errorMessage: 'India mobile number must start with 6, 7, 8, or 9',
        digitCount: digits.length,
      );
    }

    return ValidationResult.valid(digitCount: 10);
  }

  /// Generic country validation
  static ValidationResult _validateGeneric(
    String cleanDigits,
    CountryPhoneInfo country,
    bool strictPrefix,
  ) {
    String digits = cleanDigits;
    final dialDigits = country.dialDigits;

    // Strip dial code if present at beginning
    if (digits.startsWith(dialDigits) && digits.length > dialDigits.length) {
      digits = digits.substring(dialDigits.length);
    }

    if (digits.length < country.minLength) {
      return ValidationResult.invalid(
        errorMessage: '${country.name} number requires at least ${country.minLength} digits (current: ${digits.length})',
        digitCount: digits.length,
        expectedMinDigits: country.minLength,
        expectedMaxDigits: country.maxLength,
      );
    }

    if (digits.length > country.maxLength) {
      return ValidationResult.invalid(
        errorMessage: '${country.name} number cannot exceed ${country.maxLength} digits (current: ${digits.length})',
        digitCount: digits.length,
        expectedMinDigits: country.minLength,
        expectedMaxDigits: country.maxLength,
      );
    }

    if (strictPrefix && country.validPrefixes.isNotEmpty && !country.isValidPrefix(digits)) {
      return ValidationResult.invalid(
        errorMessage: 'Number does not start with a recognized prefix for ${country.name}',
        digitCount: digits.length,
      );
    }

    return ValidationResult.valid(digitCount: digits.length);
  }
}

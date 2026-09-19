import 'country_phone_info.dart';

/// The result of parsing and validating a phone number.
class PhoneNumberResult {
  /// The original input provided by the user.
  final String rawInput;

  /// All numeric digits extracted from the input.
  final String cleanDigits;

  /// The identified country, if matched.
  final CountryPhoneInfo? country;

  /// National significant number digits (excluding country code and leading trunk zero where applicable).
  final String nationalDigits;

  /// E.164 standard formatted phone number (e.g., `+8801712345678`).
  final String? e164;

  /// Human-friendly international format (e.g., `+880 1712-345678`).
  final String? international;

  /// Human-friendly national format (e.g., `01712-345678`).
  final String? national;

  /// Whether the phone number satisfies length, prefix, and country-specific rules.
  final bool isValid;

  /// Human-readable explanation if validation failed.
  final String? errorMessage;

  const PhoneNumberResult({
    required this.rawInput,
    required this.cleanDigits,
    this.country,
    required this.nationalDigits,
    this.e164,
    this.international,
    this.national,
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'PhoneNumberResult(isValid: $isValid, e164: $e164, national: $national, country: ${country?.name}, error: $errorMessage)';
  }
}

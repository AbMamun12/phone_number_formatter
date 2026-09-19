/// Represents metadata and formatting rules for a country's telephone numbering plan.
class CountryPhoneInfo {
  /// Name of the country (e.g., "Bangladesh", "United States").
  final String name;

  /// ISO 3166-1 alpha-2 code (e.g., "BD", "US").
  final String isoCode;

  /// International dialing code including the leading '+' (e.g., "+880", "+1").
  final String dialCode;

  /// Flag emoji for the country (e.g., "🇧🇩", "🇺🇸").
  final String flagEmoji;

  /// Minimum number of digits for a valid national number (excluding country code).
  final int minLength;

  /// Maximum number of digits for a valid national number (excluding country code).
  final int maxLength;

  /// Formatting mask for national display.
  /// Use `#` as placeholders for digits. Other characters are separators.
  /// Example: `"01###-######"` for Bangladesh, `"(###) ###-####"` for US.
  final String formatMask;

  /// Optional formatting mask for international display.
  /// Example: `"+880 1###-######"`.
  final String? internationalMask;

  /// Optional list of valid national prefixes (e.g., operator codes like '013', '017').
  final List<String> validPrefixes;

  /// National trunk prefix (usually '0'), if used in local dialing.
  final String? trunkPrefix;

  /// Example national phone number for reference and UI placeholder.
  final String exampleNumber;

  const CountryPhoneInfo({
    required this.name,
    required this.isoCode,
    required this.dialCode,
    required this.flagEmoji,
    required this.minLength,
    required this.maxLength,
    required this.formatMask,
    this.internationalMask,
    this.validPrefixes = const [],
    this.trunkPrefix,
    required this.exampleNumber,
  });

  /// Digits of the dial code without the '+' sign.
  String get dialDigits => dialCode.replaceAll('+', '');

  /// Checks if national digits length falls within [minLength] and [maxLength].
  bool isValidLength(String digits) {
    final len = digits.length;
    return len >= minLength && len <= maxLength;
  }

  /// The formatting mask used when the country dial code is already displayed
  /// separately (i.e. without the local trunk prefix '0').
  String get dialCodeNumberMask {
    if (trunkPrefix != null && trunkPrefix!.isNotEmpty) {
      // If formatMask starts with '#' for the trunk prefix, remove one '#' from the start
      if (formatMask.startsWith('#')) {
        var mask = formatMask.substring(1);
        // also remove any leading separator space or hyphen
        while (mask.startsWith(' ') || mask.startsWith('-')) {
          mask = mask.substring(1);
        }
        return mask;
      }
    }
    return formatMask;
  }

  /// Example number formatted without trunk prefix (ideal for input hint when dial code is shown).
  String get exampleWithoutTrunk {
    if (trunkPrefix != null && trunkPrefix!.isNotEmpty && exampleNumber.startsWith(trunkPrefix!)) {
      var ex = exampleNumber.substring(trunkPrefix!.length);
      while (ex.startsWith(' ') || ex.startsWith('-')) {
        ex = ex.substring(1);
      }
      return ex;
    }
    return exampleNumber;
  }

  /// Strips dial code (if present) and local trunk prefix (e.g. leading '0') from digits.
  String stripTrunk(String rawDigits) {
    var digits = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(dialDigits)) {
      digits = digits.substring(dialDigits.length);
    }
    if (trunkPrefix != null && trunkPrefix!.isNotEmpty && digits.startsWith(trunkPrefix!)) {
      digits = digits.substring(trunkPrefix!.length);
    }
    return digits;
  }

  /// Checks if national digits start with an expected prefix, if prefix restrictions exist.
  bool isValidPrefix(String digits) {
    if (validPrefixes.isEmpty) return true;
    return validPrefixes.any((prefix) => digits.startsWith(prefix));
  }

  /// Applies this country's [formatMask] (or [maskOverride]) to a string of raw digits.
  String applyMask(String rawDigits, {String? maskOverride}) {
    final mask = maskOverride ?? formatMask;
    final cleanDigits = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) return '';

    final buffer = StringBuffer();
    int digitIdx = 0;

    for (int i = 0; i < mask.length && digitIdx < cleanDigits.length; i++) {
      final char = mask[i];
      if (char == '#') {
        buffer.write(cleanDigits[digitIdx]);
        digitIdx++;
      } else {
        buffer.write(char);
      }
    }

    // Append any trailing digits if mask is shorter than input
    if (digitIdx < cleanDigits.length) {
      buffer.write(cleanDigits.substring(digitIdx));
    }

    return buffer.toString();
  }

  /// Generates a unicode flag emoji from an ISO 3166-1 alpha-2 code.
  static String flagEmojiFromIso(String isoCode) {
    if (isoCode.length != 2) return '🌐';
    final upper = isoCode.toUpperCase();
    final firstChar = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondChar = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  @override
  String toString() => '$flagEmoji $name ($dialCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhoneInfo &&
          runtimeType == other.runtimeType &&
          isoCode.toUpperCase() == other.isoCode.toUpperCase();

  @override
  int get hashCode => isoCode.toUpperCase().hashCode;
}

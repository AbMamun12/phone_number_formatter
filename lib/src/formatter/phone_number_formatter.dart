import 'dart:math';
import 'package:flutter/services.dart';

import '../data/countries_data.dart';
import '../models/country_phone_info.dart';

/// Flutter [TextInputFormatter] that formats phone numbers in real-time as the user types,
/// preserving cursor position and applying country-specific masks and length constraints.
class PhoneNumberInputFormatter extends TextInputFormatter {
  /// Selected country rules. If null, defaults to Bangladesh.
  CountryPhoneInfo country;

  /// Whether this formatter is used alongside a country dial code display
  /// (e.g. in [PhoneInputField] where `+880` or `+44` is already shown as a prefix).
  ///
  /// When true:
  /// - Leading trunk prefixes (like local '0' in Bangladesh `01...` or UK `07...`) are automatically stripped.
  /// - Any pasted country dialing codes are automatically stripped.
  /// - Uses [CountryPhoneInfo.dialCodeNumberMask] (e.g. `####-######` for Bangladesh, 10 digits).
  final bool isWithDialCode;

  /// Whether to format with the country's international format (e.g., `+880 1712-345678`).
  final bool isInternational;

  /// Whether to automatically remove leading trunk prefix (e.g. '0') when dialing internationally
  /// or when [isWithDialCode] is true.
  final bool autoStripTrunkPrefix;

  /// Optional custom mask overriding the country's default mask.
  final String? customMask;

  /// Whether to automatically clamp input to the country's max digit length.
  final bool enforceMaxLength;

  /// Callback fired whenever formatted text or validation status changes.
  final void Function(String rawDigits, String formattedText)? onChanged;

  PhoneNumberInputFormatter({
    CountryPhoneInfo? country,
    this.isWithDialCode = false,
    this.isInternational = false,
    this.autoStripTrunkPrefix = false,
    this.customMask,
    this.enforceMaxLength = true,
    this.onChanged,
  }) : country = country ?? CountriesData.defaultCountry;

  /// Update active country dynamically.
  void updateCountry(CountryPhoneInfo newCountry) {
    country = newCountry;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If text was cleared, allow immediately
    if (newValue.text.isEmpty) {
      onChanged?.call('', '');
      return newValue;
    }

    // Determine the mask to use
    final mask = customMask ??
        (isWithDialCode
            ? country.dialCodeNumberMask
            : (isInternational && country.internationalMask != null
                ? country.internationalMask!
                : country.formatMask));

    // Extract all raw digits from new text
    var cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Check if leading dial code was pasted in (e.g., "+880..." or "880...")
    final dialDigits = country.dialDigits;
    bool strippedDialCode = false;
    if (isWithDialCode && cleanDigits.startsWith(dialDigits) && cleanDigits.length > dialDigits.length) {
      cleanDigits = cleanDigits.substring(dialDigits.length);
      strippedDialCode = true;
    }

    // Automatically strip trunk prefix (e.g., leading '0' for Bangladesh, UK, Germany, etc.)
    // when used with dial code or when autoStripTrunkPrefix is enabled
    bool strippedTrunk = false;
    final trunk = country.trunkPrefix;
    if ((isWithDialCode || autoStripTrunkPrefix) &&
        trunk != null &&
        trunk.isNotEmpty &&
        cleanDigits.startsWith(trunk)) {
      cleanDigits = cleanDigits.substring(trunk.length);
      strippedTrunk = true;
    }

    // If text only contained the trunk '0' and was stripped, return empty
    if (cleanDigits.isEmpty) {
      onChanged?.call('', '');
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Enforce max digits if configured
    if (enforceMaxLength) {
      // If used with dial code, max allowed is without trunk prefix
      final maxAllowed = (isWithDialCode && trunk != null && trunk.isNotEmpty)
          ? (country.maxLength - trunk.length)
          : country.maxLength;

      if (cleanDigits.length > maxAllowed) {
        cleanDigits = cleanDigits.substring(0, maxAllowed);
      }
    }

    // Format the clean digits according to the mask
    final formatted = _applyMaskToDigits(cleanDigits, mask);

    // Count pure digits up to the current selection cursor in newValue
    int newDigitsBeforeCursor = newValue.text
        .substring(0, min(newValue.selection.end, newValue.text.length))
        .replaceAll(RegExp(r'\D'), '')
        .length;

    // Adjust cursor if dial code or trunk prefix was stripped
    if (strippedDialCode) {
      newDigitsBeforeCursor = max(0, newDigitsBeforeCursor - dialDigits.length);
    }
    if (strippedTrunk && trunk != null) {
      newDigitsBeforeCursor = max(0, newDigitsBeforeCursor - trunk.length);
    }

    // Calculate new cursor position based on digit count
    int newCursorPos = 0;
    int digitCount = 0;

    for (int i = 0; i < formatted.length; i++) {
      if (digitCount == newDigitsBeforeCursor) {
        newCursorPos = i;
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      newCursorPos = i + 1;
    }

    newCursorPos = newCursorPos.clamp(0, formatted.length);

    onChanged?.call(cleanDigits, formatted);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Formats raw digits with the mask (# as digit placeholder).
  static String _applyMaskToDigits(String digits, String mask) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    int digitIdx = 0;

    for (int i = 0; i < mask.length && digitIdx < digits.length; i++) {
      final char = mask[i];
      if (char == '#') {
        buffer.write(digits[digitIdx]);
        digitIdx++;
      } else {
        buffer.write(char);
      }
    }

    // If more digits remain beyond the mask, append them
    if (digitIdx < digits.length) {
      buffer.write(digits.substring(digitIdx));
    }

    return buffer.toString();
  }
}

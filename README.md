# Phone Number Formatter

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue.svg)](https://pub.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, zero-native-dependency Flutter and pure Dart package for formatting, parsing, and validating international phone numbers. Features built-in dialing metadata for **over 240+ countries and territories**, real-time `TextInputFormatter` for Flutter text fields, and strict country-specific condition validations—such as the **Bangladesh 11-digit national rule** (`01XXXXXXXXX`).

---

## 🌟 Key Features

- 🇧🇩 **Bangladesh Phone Number Rules**:
  - Validates exact **11-digit** national mobile format (`01XXXXXXXXX`) and **10-digit** international format after `+880` (`1XXXXXXXXX`).
  - Automatically strips leading trunk `0` in real time when dial code `+880` is selected.
  - Generates standardized **E.164** (`+8801XXXXXXXXX`) and international formatting (`+880 1XXX-XXXXXX`).
  - **Future-Proof**: Accepts newly allocated operator prefixes by default (`strictPrefix: false`), with optional strict mode.
- 🌐 **Global Country Coverage (240+ Countries)**:
  - Complete phone metadata for all global countries (ISO-2 code, dial codes, flag emojis, min/max lengths, format masks).
  - Conditions for US/Canada (10-digit NANP rules), India (10 digits), UK, Germany, Saudi Arabia, UAE, and more.
- ⚡ **Real-Time `TextInputFormatter`**:
  - Smooth dynamic formatting as the user types without jumping or losing cursor positions.
  - Automatically clamps extra digits beyond a country's maximum allowed length without needing manual `maxLength` on `TextField`.
- 📱 **Interactive `PhoneInputField` Widget**:
  - Ready-to-use input field with searchable modal country picker and flag emojis.
  - Live validation indicators (customizable valid checkmark / invalid warning badge colors and icons).
- 🧩 **Pure Dart & Flutter**:
  - Zero C/C++ or heavy native binaries. Fully compatible with iOS, Android, Web, macOS, Windows, and Linux.

---

## 🚀 Getting Started

Add `phone_number_formatter` to your `pubspec.yaml`:

```yaml
dependencies:
  phone_number_formatter: ^1.0.0
```

Then import it in your Dart code:

```dart
import 'package:phone_number_formatter/phone_number_formatter.dart';
```

---

## 📖 Usage Examples

### 1. Ready-to-use `PhoneInputField` Widget

```dart
import 'package:flutter/material.dart';
import 'package:phone_number_formatter/phone_number_formatter.dart';

class MyPhonePage extends StatefulWidget {
  @override
  State<MyPhonePage> createState() => _MyPhonePageState();
}

class _MyPhonePageState extends State<MyPhonePage> {
  final TextEditingController _controller = TextEditingController();
  PhoneNumberResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Input')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PhoneInputField(
              controller: _controller,
              initialCountry: CountriesData.bangladesh,
              showValidationBadge: true,
              validBadgeColor: Colors.green,
              invalidBadgeColor: Colors.orange,
              onPhoneChanged: (result) {
                setState(() {
                  _result = result;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              Text('Valid: ${_result!.isValid}'),
              Text('National: ${_result!.national}'),
              Text('E.164: ${_result!.e164}'),
              Text('International: ${_result!.international}'),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 2. `PhoneInputField` Properties Reference

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `initialCountry` | `CountryPhoneInfo?` | `CountriesData.bangladesh` | Initial selected country |
| `controller` | `TextEditingController?` | `null` | Controller for the phone input text |
| `showValidationBadge` | `bool` | `true` | Show or hide the validation badge icon |
| `validBadgeColor` | `Color?` | `Colors.green` | Custom color for the valid badge icon |
| `invalidBadgeColor` | `Color?` | `Colors.orange` | Custom color for the invalid badge icon |
| `validBadgeIcon` | `IconData?` | `Icons.check_circle` | Custom icon for the valid badge |
| `invalidBadgeIcon` | `IconData?` | `Icons.error_outline` | Custom icon for the invalid badge |
| `enableCountryPicker` | `bool` | `true` | Enable or disable the country picker button |
| `isInternational` | `bool` | `false` | Apply international mask instead of national mask |
| `countryFilter` | `List<String>?` | `null` | Restrict country picker to specific ISO codes (e.g. `['BD', 'US']`) |
| `searchHintText` | `String?` | `'Search country...'` | Placeholder in country picker search bar |
| `enabled` | `bool` | `true` | Enable or disable user interaction |
| `readOnly` | `bool` | `false` | Make field read-only |
| `textInputAction` | `TextInputAction?` | `TextInputAction.done` | Keyboard action button |
| `decoration` | `InputDecoration?` | `null` | Custom Flutter input decoration styling |
| `onPhoneChanged` | `ValueChanged<PhoneNumberResult>?` | `null` | Triggered when phone number changes with detailed parsed result |
| `onCountryChanged` | `ValueChanged<CountryPhoneInfo>?` | `null` | Triggered when a new country is selected |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Triggered when user submits keyboard |

---

### 3. Standalone `TextInputFormatter` for Any `TextField`

You can attach `PhoneNumberInputFormatter` directly to any standard Flutter `TextField` or `TextFormField`:

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    PhoneNumberInputFormatter(
      country: CountriesData.bangladesh, // Target country formatting
      enforceMaxLength: true,             // Clamps to max digits for country
      isWithDialCode: false,              // Strips leading 0 if dial code is prefixed
    ),
  ],
  decoration: const InputDecoration(
    hintText: '01712-345678',
    border: OutlineInputBorder(),
  ),
)
```

---

### 4. Parsing & Formatting Strings

```dart
// Parse a Bangladesh local number:
final res = PhoneNumberParser.parse('01712345678');

print(res.isValid);               // true
print(res.national);              // "01712-345678"
print(res.international);         // "+880 1712-345678"
print(res.e164);                  // "+8801712345678"
print(res.country?.name);         // "Bangladesh"

// Parse an international number:
final usRes = PhoneNumberParser.parse('+12015550123');
print(usRes.national);            // "(201) 555-0123"
print(usRes.country?.isoCode);    // "US"
```

---

### 5. Validating Numbers

```dart
// Bangladesh 11-digit validation
final valid = PhoneNumberValidator.validate('01712345678', country: CountriesData.bangladesh);
print(valid.isValid); // true

// Bangladesh under 11 digits:
final short = PhoneNumberValidator.validate('017123456', country: CountriesData.bangladesh);
print(short.isValid);      // false
print(short.errorMessage); // "Bangladesh phone number must be exactly 11 digits (current: 9)"

// Bangladesh flexible validation (accepts all 11-digit operator series):
final validNumber = PhoneNumberValidator.validate('01234534564', country: CountriesData.bangladesh);
print(validNumber.isValid); // true

// Optional strict operator code checking:
final badPrefix = PhoneNumberValidator.validate('01212345678', country: CountriesData.bangladesh, strictPrefix: true);
print(badPrefix.isValid);      // false
print(badPrefix.errorMessage); // "Invalid operator code. Valid prefixes are 013, 014, 015, 016, 017, 018, 019"
```

---

### 6. Accessing the Global Country Registry

```dart
// Look up by ISO-2 code
final country = CountriesData.findByIso('BD');

// Look up by dial code
final country = CountriesData.findByDialCode('+880');

// List of all 240+ countries
final List<CountryPhoneInfo> allCountries = CountriesData.all;
```

---

## 🇧🇩 Bangladesh Numbering Plan Reference

| Operator | Dial Prefix | Format Mask | Digit Count |
| :--- | :--- | :--- | :--- |
| **Grameenphone (GP)** | `017` | `017XX-XXXXXX` | 11 digits |
| **Skitto** | `013` | `013XX-XXXXXX` | 11 digits |
| **Banglalink** | `014`, `019` | `014XX-XXXXXX` / `019XX-XXXXXX` | 11 digits |
| **Robi** | `018` | `018XX-XXXXXX` | 11 digits |
| **Airtel** | `016` | `016XX-XXXXXX` | 11 digits |
| **Teletalk** | `015` | `015XX-XXXXXX` | 11 digits |

---

## 🧪 Testing

Run automated tests:

```bash
flutter test
```

Run linter:

```bash
flutter analyze
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

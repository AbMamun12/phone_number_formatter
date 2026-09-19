# Phone Number Formatter

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue.svg)](https://pub.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, zero-native-dependency Flutter and pure Dart package for formatting, parsing, and validating international phone numbers. Features built-in dialing metadata for **over 240+ countries and territories**, real-time `TextInputFormatter` for Flutter text fields, and strict country-specific condition validations—such as the **Bangladesh 11-digit national rule** (`01XXXXXXXXX`).

---

## 🌟 Key Features

- 🇧🇩 **Strict Bangladesh Conditions**:
  - Validates exact **11-digit** national mobile format (`01XXXXXXXXX`).
  - Strict operator prefix checks (`013`, `014`, `015`, `016`, `017`, `018`, `019`).
  - Automatic E.164 conversion (`+8801XXXXXXXXX`) and international formatting (`+880 1XXX-XXXXXX`).
- 🌐 **Global Country Coverage**:
  - Complete phone metadata for all global countries (ISO-2 code, dial codes, emojis, min/max lengths, format masks).
  - Conditions for US/Canada (10 digits), India (10 digits starting with 6-9), UK, Germany, Saudi Arabia, UAE, and more.
- ⚡ **Real-Time `TextInputFormatter`**:
  - Smooth dynamic formatting as the user types without jumping or broken cursor positions.
  - Automatically clamps extra digits beyond a country's maximum allowed length.
- 📱 **Interactive `PhoneInputField` Widget**:
  - Ready-to-use input field with searchable modal country picker and flag emojis.
  - Live validation indicators (valid checkmark / invalid warning badge).
- 🧩 **Pure Dart & Flutter**:
  - No C/C++ or heavy native binaries. Fully compatible with iOS, Android, Web, macOS, Windows, and Linux.

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

### 2. Standalone `TextInputFormatter` for Any `TextField`

You can attach `PhoneNumberInputFormatter` directly to any standard Flutter `TextField` or `TextFormField`:

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    PhoneNumberInputFormatter(
      country: CountriesData.bangladesh, // Defaults to Bangladesh
      enforceMaxLength: true,             // Clamps to 11 digits for BD
    ),
  ],
  decoration: const InputDecoration(
    hintText: '01712-345678',
    border: OutlineInputBorder(),
  ),
)
```

---

### 3. Parsing & Formatting Strings

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

### 4. Validating Numbers

```dart
// Bangladesh 11-digit validation
final valid = PhoneNumberValidator.validate('01712345678', country: CountriesData.bangladesh);
print(valid.isValid); // true

// Bangladesh under 11 digits:
final short = PhoneNumberValidator.validate('017123456', country: CountriesData.bangladesh);
print(short.isValid);      // false
print(short.errorMessage); // "Bangladesh phone number must be exactly 11 digits (current: 9)"

// Bangladesh flexible validation (default, accepts updated operator allocations):
final validNumber = PhoneNumberValidator.validate('01234534564', country: CountriesData.bangladesh);
print(validNumber.isValid); // true

// Optional strict operator code checking:
final badPrefix = PhoneNumberValidator.validate('01212345678', country: CountriesData.bangladesh, strictPrefix: true);
print(badPrefix.isValid);      // false
print(badPrefix.errorMessage); // "Invalid operator code. Valid prefixes are 013, 014, 015, 016, 017, 018, 019"
```

---

### 5. Accessing the Global Country Registry

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

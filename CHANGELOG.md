# Changelog

All notable changes to the `phone_number_formatter` package will be documented in this file.

## [1.0.1] - 2026-09-19

- Optimized `pubspec.yaml` package description length for pub.dev Pana score.
- Added explicit platform support and discoverability topics.

## [1.0.0] - 2026-09-19

### 🚀 Initial Release

- **`PhoneInputField` Widget**:
  - Integrated country picker with flag emojis, country dial code selector, and instant search filter.
  - Live validation indicators with customizable colors (`validBadgeColor`, `invalidBadgeColor`) and icons (`validBadgeIcon`, `invalidBadgeIcon`).
  - Customizable decoration, keyboard action (`textInputAction`), read-only mode, and country filter (`countryFilter`).
- **`PhoneNumberInputFormatter`**:
  - Real-time `TextInputFormatter` for smooth, dynamic formatting without cursor jumping.
  - Automatic leading trunk prefix stripping (`0`) when dial codes are present.
  - Automatic maximum digit length enforcement (`enforceMaxLength`).
- **`PhoneNumberValidator` & `PhoneNumberParser`**:
  - Full support for **240+ countries and territories**.
  - Specialized **Bangladesh 11-digit national rule** (`01XXXXXXXXX`) and 10-digit format after `+880`.
  - Flexible operator prefix checking by default (`strictPrefix: false`) to accept newly allocated operator series, with optional strict validation mode.
  - Standardized **E.164** format output (`+8801XXXXXXXXX`) and clean digit representations.
- **Pure Dart & Zero Native Dependencies**:
  - Fully compatible with iOS, Android, Web, macOS, Windows, and Linux.

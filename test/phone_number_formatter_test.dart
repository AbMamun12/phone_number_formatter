import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_formatter/phone_number_formatter.dart';

void main() {
  group('Bangladesh 11-Digit Condition Tests', () {
    test('Validates 11-digit national format for Bangladesh', () {
      final res1 = PhoneNumberValidator.validate('01712345678', country: CountriesData.bangladesh);
      expect(res1.isValid, isTrue);

      final res2 = PhoneNumberValidator.validate('01987654321', country: CountriesData.bangladesh);
      expect(res2.isValid, isTrue);

      final res3 = PhoneNumberValidator.validate('01300000000', country: CountriesData.bangladesh);
      expect(res3.isValid, isTrue);
    });

    test('Rejects Bangladesh number with less than 11 digits', () {
      final res = PhoneNumberValidator.validate('0171234567', country: CountriesData.bangladesh);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('must be exactly 11 digits'));
    });

    test('Rejects Bangladesh number with more than 11 digits in national format', () {
      final res = PhoneNumberValidator.validate('017123456789', country: CountriesData.bangladesh);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains('cannot exceed 11 digits'));
    });

    test('Validates 10-digit international and 11-digit national for any Bangladesh operator allocation', () {
      // 01234534564 in national format (11 digits) is valid
      final res1 = PhoneNumberValidator.validate('01234534564', country: CountriesData.bangladesh);
      expect(res1.isValid, isTrue);

      // 1234534564 in international mode (10 digits) is valid
      final res2 = PhoneNumberValidator.validate('1234534564', country: CountriesData.bangladesh);
      expect(res2.isValid, isTrue);
    });

    test('Rejects Bangladesh number with invalid operator prefix only when strictPrefix is true', () {
      final res1 = PhoneNumberValidator.validate(
        '01212345678',
        country: CountriesData.bangladesh,
        strictPrefix: true,
      );
      expect(res1.isValid, isFalse);
      expect(res1.errorMessage, contains('Invalid operator code'));
    });

    test('Validates Bangladesh international format (+880)', () {
      // +880 followed by 10 digits
      final res = PhoneNumberValidator.validate('+8801712345678', country: CountriesData.bangladesh);
      expect(res.isValid, isTrue);

      // +880 with less than 10 digits
      final resShort = PhoneNumberValidator.validate('+88017123456', country: CountriesData.bangladesh);
      expect(resShort.isValid, isFalse);
      expect(resShort.errorMessage, contains('requires 10 digits after +880'));
    });

    test('PhoneNumberParser correctly formats Bangladesh national and E.164', () {
      final parsed = PhoneNumberParser.parse('01712345678', defaultCountry: CountriesData.bangladesh);
      expect(parsed.isValid, isTrue);
      expect(parsed.national, '01712-345678');
      expect(parsed.international, '+880 1712-345678');
      expect(parsed.e164, '+8801712345678');
    });
  });

  group('International Countries Validation Tests', () {
    test('United States 10-digit validation', () {
      final valid = PhoneNumberValidator.validate('2015550123', country: CountriesData.unitedStates);
      expect(valid.isValid, isTrue);

      final invalidShort = PhoneNumberValidator.validate('201555012', country: CountriesData.unitedStates);
      expect(invalidShort.isValid, isFalse);

      final invalidAreaCode = PhoneNumberValidator.validate('0015550123', country: CountriesData.unitedStates);
      expect(invalidAreaCode.isValid, isFalse);
      expect(invalidAreaCode.errorMessage, contains('Area code cannot start with 0'));
    });

    test('India 10-digit validation', () {
      final inCountry = CountriesData.findByIso('IN')!;
      final valid = PhoneNumberValidator.validate('9876543210', country: inCountry);
      expect(valid.isValid, isTrue);

      // Default is flexible (strictPrefix = false) to support all new operator series
      final flexible = PhoneNumberValidator.validate('2876543210', country: inCountry);
      expect(flexible.isValid, isTrue);

      // Strict prefix check can be enabled optionally
      final invalidPrefix = PhoneNumberValidator.validate('2876543210', country: inCountry, strictPrefix: true);
      expect(invalidPrefix.isValid, isFalse);
    });

    test('United Kingdom validation', () {
      final ukCountry = CountriesData.findByIso('GB')!;
      final valid = PhoneNumberValidator.validate('07123456789', country: ukCountry);
      expect(valid.isValid, isTrue);
    });

    test('Country registry contains over 60 international countries', () {
      expect(CountriesData.all.length, greaterThan(60));
      expect(CountriesData.findByIso('BD'), isNotNull);
      expect(CountriesData.findByIso('US'), isNotNull);
      expect(CountriesData.findByIso('IN'), isNotNull);
      expect(CountriesData.findByIso('GB'), isNotNull);
      expect(CountriesData.findByIso('SA'), isNotNull);
      expect(CountriesData.findByIso('AE'), isNotNull);
    });
  });

  group('PhoneNumberInputFormatter Real-Time Formatting Tests', () {
    test('Formats Bangladesh number with 01###-###### mask as user types', () {
      final formatter = PhoneNumberInputFormatter(country: CountriesData.bangladesh);

      // User types 017
      var result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '017',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '017');

      // User types full number: 01712345678
      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: '01712345678',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(result.text, '01712-345678');
      expect(result.selection.end, 12);
    });

    test('Clamps input to max length when enforceMaxLength is true', () {
      final formatter = PhoneNumberInputFormatter(
        country: CountriesData.bangladesh,
        enforceMaxLength: true,
      );

      // User enters 13 digits
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '0171234567899',
          selection: TextSelection.collapsed(offset: 13),
        ),
      );
      // Clamped to 11 digits: 01712-345678
      expect(result.text, '01712-345678');
    });

    test('Formats US number with (###) ###-#### mask', () {
      final formatter = PhoneNumberInputFormatter(country: CountriesData.unitedStates);

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '2015550123',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
      expect(result.text, '(201) 555-0123');
    });

    test('Automatically strips leading trunk 0 when isWithDialCode is true for Bangladesh', () {
      final formatter = PhoneNumberInputFormatter(
        country: CountriesData.bangladesh,
        isWithDialCode: true,
      );

      // User types '0'
      var res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      // '0' is stripped, result remains empty
      expect(res.text, '');

      // User pastes full local number: '01732412342'
      res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '01732412342',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      // Leading 0 stripped, 10 digits formatted as 1732-412342
      expect(res.text, '1732-412342');
    });

    test('Automatically strips leading trunk 0 for other countries (UK, Saudi Arabia)', () {
      // UK: local 07123456789 -> with dial code +44 becomes 7123 456789
      final ukFormatter = PhoneNumberInputFormatter(
        country: CountriesData.findByIso('GB')!,
        isWithDialCode: true,
      );
      final ukRes = ukFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '07123456789',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      expect(ukRes.text, '7123 456789');

      // Saudi Arabia: local 0512345678 -> with dial code +966 becomes 51 234 5678
      final saFormatter = PhoneNumberInputFormatter(
        country: CountriesData.findByIso('SA')!,
        isWithDialCode: true,
      );
      final saRes = saFormatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '0512345678',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
      expect(saRes.text, '51 234 5678');
    });
  });

  group('Default Country Configuration Tests', () {
    test('Default fallback country is Bangladesh', () {
      expect(CountriesData.defaultCountry.isoCode, 'BD');
    });

    test('Can configure initialCountry directly on formatter or widget', () {
      final formatterUS = PhoneNumberInputFormatter(country: CountriesData.unitedStates);
      expect(formatterUS.country.isoCode, 'US');

      final formatterBD = PhoneNumberInputFormatter();
      expect(formatterBD.country.isoCode, 'BD');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:phone_number_formatter/phone_number_formatter.dart';

void main() {
  runApp(const PhoneNumberFormatterApp());
}

class PhoneNumberFormatterApp extends StatelessWidget {
  const PhoneNumberFormatterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Number Formatter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A4E),
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final TextEditingController _controller = TextEditingController();
  PhoneNumberResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Number Formatter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ready-to-use PhoneInputField Widget
            const Text(
              '1. PhoneInputField Widget',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            PhoneInputField(
              controller: _controller,
              initialCountry: CountriesData.bangladesh, // Set default country
              enableCountryPicker: true,                 // Show country picker & flag
              showValidationBadge: true,                 // Show live valid/invalid badge
              onPhoneChanged: (result) {
                setState(() {
                  _result = result;
                });
              },
            ),

            const SizedBox(height: 20),

            // 2. Display Parsed Properties
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_result!.isValid ? "VALID ✅" : "INVALID ❌"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _result!.isValid ? Colors.green : Colors.red,
                        ),
                      ),
                      const Divider(height: 16),
                      Text('Country: ${_result!.country?.name} (${_result!.country?.dialCode})'),
                      Text('National Format: ${_result!.national ?? "-"}'),
                      Text('International: ${_result!.international ?? "-"}'),
                      Text('E.164 Format: ${_result!.e164 ?? "-"}'),
                      Text('Clean Digits: ${_result!.cleanDigits}'),
                      if (_result!.errorMessage != null)
                        Text(
                          'Error: ${_result!.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 3. Standalone TextInputFormatter on standard TextField
            const Text(
              '2. Standalone TextInputFormatter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.phone,
              inputFormatters: [
                PhoneNumberInputFormatter(
                  country: CountriesData.bangladesh, // 11-digit Bangladesh mask (01712-345678)
                  enforceMaxLength: true,
                ),
              ],
              decoration: const InputDecoration(
                hintText: '01712-345678 (National 11 Digits)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

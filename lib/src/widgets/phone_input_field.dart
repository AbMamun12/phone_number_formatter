import 'package:flutter/material.dart';

import '../data/countries_data.dart';
import '../formatter/phone_number_formatter.dart';
import '../models/country_phone_info.dart';
import '../models/phone_number_result.dart';
import '../parser/phone_number_parser.dart';

/// A complete, customizable Flutter phone input field with country picker,
/// real-time formatting mask, and live validation status.
class PhoneInputField extends StatefulWidget {
  /// Initial country selection. Defaults to Bangladesh.
  final CountryPhoneInfo? initialCountry;

  /// Text controller for the phone number input.
  final TextEditingController? controller;

  /// Callback called whenever country is selected from the picker.
  final ValueChanged<CountryPhoneInfo>? onCountryChanged;

  /// Callback called whenever input or country changes with detailed parsed result.
  final ValueChanged<PhoneNumberResult>? onPhoneChanged;

  /// Input decoration to customize the text field appearance.
  final InputDecoration? decoration;

  /// Whether to show live validation indicator (valid/invalid icon & helper).
  final bool showValidationBadge;

  /// Whether to allow country selection.
  final bool enableCountryPicker;

  /// Whether to format with the country's international format.
  final bool isInternational;

  /// Whether the input field is enabled.
  final bool enabled;

  /// Whether the input field is read-only.
  final bool readOnly;

  /// The action to take when the user presses Done/Next/Search on the keyboard.
  final TextInputAction? textInputAction;

  /// Callback called when the user submits the text field (e.g. presses Enter/Done).
  final ValueChanged<String>? onSubmitted;

  /// Optional list of ISO codes to restrict available countries in the picker (e.g. `['BD', 'US', 'IN']`).
  final List<String>? countryFilter;

  /// Optional custom hint text for the country picker search bar.
  final String? searchHintText;

  /// Focus node for managing keyboard focus.
  final FocusNode? focusNode;

  /// Custom color for the valid badge icon. Defaults to [Colors.green].
  final Color? validBadgeColor;

  /// Custom color for the invalid/incomplete badge icon. Defaults to [Colors.orange].
  final Color? invalidBadgeColor;

  /// Custom icon for the valid badge. Defaults to [Icons.check_circle].
  final IconData? validBadgeIcon;

  /// Custom icon for the invalid/incomplete badge. Defaults to [Icons.error_outline].
  final IconData? invalidBadgeIcon;

  /// Text style for the input field.
  final TextStyle? style;

  const PhoneInputField({
    super.key,
    this.initialCountry,
    this.controller,
    this.onCountryChanged,
    this.onPhoneChanged,
    this.decoration,
    this.showValidationBadge = true,
    this.validBadgeColor,
    this.invalidBadgeColor,
    this.validBadgeIcon,
    this.invalidBadgeIcon,
    this.enableCountryPicker = true,
    this.isInternational = false,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
    this.countryFilter,
    this.searchHintText,
    this.focusNode,
    this.style,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _controller;
  late CountryPhoneInfo _selectedCountry;
  late PhoneNumberInputFormatter _formatter;
  PhoneNumberResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _selectedCountry = widget.initialCountry ?? CountriesData.defaultCountry;
    _initFormatter();
    // If controller already has text with a leading trunk '0', strip it when country picker is active
    if (widget.enableCountryPicker && _controller.text.isNotEmpty) {
      final stripped = _selectedCountry.stripTrunk(_controller.text);
      if (stripped != _controller.text) {
        _controller.text = stripped;
      }
    }
    _controller.addListener(_handleTextChange);
  }

  void _initFormatter() {
    _formatter = PhoneNumberInputFormatter(
      country: _selectedCountry,
      isWithDialCode: widget.enableCountryPicker,
      isInternational: widget.isInternational,
      autoStripTrunkPrefix: true,
    );
  }

  void _handleTextChange() {
    final text = _controller.text.trim();
    final parseInput = widget.enableCountryPicker && !text.startsWith('+')
        ? '${_selectedCountry.dialCode}$text'
        : text;
    final result = PhoneNumberParser.parse(
      parseInput,
      defaultCountry: _selectedCountry,
    );
    setState(() {
      _lastResult = result;
    });
    widget.onPhoneChanged?.call(result);
  }

  @override
  void didUpdateWidget(PhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCountry != null &&
        widget.initialCountry != oldWidget.initialCountry &&
        widget.initialCountry != _selectedCountry) {
      _selectedCountry = widget.initialCountry!;
      _formatter.updateCountry(_selectedCountry);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleTextChange();
        }
      });
    }
  }

  void _onCountrySelected(CountryPhoneInfo country) {
    if (_selectedCountry == country) return;
    setState(() {
      _selectedCountry = country;
      _formatter.updateCountry(country);
      if (widget.enableCountryPicker && _controller.text.isNotEmpty) {
        final stripped = country.stripTrunk(_controller.text);
        if (stripped != _controller.text) {
          _controller.text = stripped;
        }
      }
    });
    widget.onCountryChanged?.call(country);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleTextChange();
      }
    });
  }

  void _showCountryPicker() {
    if (!widget.enabled || widget.readOnly) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
        countryFilter: widget.countryFilter,
        searchHintText: widget.searchHintText,
        onSelected: (country) {
          Navigator.pop(context);
          _onCountrySelected(country);
        },
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _lastResult?.isValid ?? false;
    final hasText = _controller.text.isNotEmpty;

    Widget? suffixIcon;
    if (widget.showValidationBadge && hasText) {
      suffixIcon = Icon(
        isValid
            ? (widget.validBadgeIcon ?? Icons.check_circle)
            : (widget.invalidBadgeIcon ?? Icons.error_outline),
        color: isValid
            ? (widget.validBadgeColor ?? Colors.green)
            : (widget.invalidBadgeColor ?? Colors.orange),
        size: 20,
      );
    }

    final effectiveHint = widget.enableCountryPicker
        ? _selectedCountry.exampleWithoutTrunk
        : _selectedCountry.exampleNumber;

    final defaultDecoration = InputDecoration(
      hintText: effectiveHint,
      prefixIcon: widget.enableCountryPicker
          ? InkWell(
              onTap: widget.enabled && !widget.readOnly ? _showCountryPicker : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.dialCode,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (widget.enabled && !widget.readOnly) ...[
                      const Icon(Icons.arrow_drop_down, size: 20),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            )
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.phone,
      inputFormatters: [_formatter],
      style: widget.style,
      decoration: (widget.decoration ?? defaultDecoration).copyWith(
        hintText: widget.decoration?.hintText ?? effectiveHint,
        prefixIcon: widget.decoration?.prefixIcon ?? defaultDecoration.prefixIcon,
        suffixIcon: widget.decoration?.suffixIcon ?? suffixIcon,
      ),
    );
  }
}

/// Searchable modal bottom sheet for picking a country.
class _CountryPickerSheet extends StatefulWidget {
  final CountryPhoneInfo selectedCountry;
  final List<String>? countryFilter;
  final String? searchHintText;
  final ValueChanged<CountryPhoneInfo> onSelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    this.countryFilter,
    this.searchHintText,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<CountryPhoneInfo> _availableCountries;
  List<CountryPhoneInfo> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    if (widget.countryFilter != null && widget.countryFilter!.isNotEmpty) {
      final filterUpper = widget.countryFilter!.map((c) => c.toUpperCase()).toSet();
      _availableCountries = CountriesData.all
          .where((c) => filterUpper.contains(c.isoCode.toUpperCase()))
          .toList();
    } else {
      _availableCountries = CountriesData.all;
    }
    _filteredCountries = _availableCountries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filteredCountries = _availableCountries;
      } else {
        _filteredCountries = _availableCountries.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.dialCode.contains(q) ||
              c.isoCode.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearchText = _searchController.text.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search by country or dial code...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: hasSearchText
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: theme.disabledColor),
                          const SizedBox(height: 8),
                          Text(
                            'No country found for "${_searchController.text}"',
                            style: TextStyle(color: theme.disabledColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _filteredCountries.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected = country.isoCode == widget.selectedCountry.isoCode;

                        return ListTile(
                          leading: Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country.dialCode,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
                              ],
                            ],
                          ),
                          onTap: () => widget.onSelected(country),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

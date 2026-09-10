import 'dart:convert';
import 'dart:js_interop';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/localization/app_strings.dart';

class UserInfoForm extends StatefulWidget {
  final Future<void> Function(String name, String contact) onSubmit;
  final bool isSubmittingLead;

  const UserInfoForm({
    super.key,
    required this.onSubmit,
    this.isSubmittingLead = false,
  });

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

// National subscriber number lengths by ISO 3166-1 alpha-2 code.
// For countries with variable lengths the standard mobile length is used.
const Map<String, int> _countryPhoneLengths = {
  'EG': 10, // Egypt
  'SA': 9,  // Saudi Arabia
  'AE': 9,  // UAE
  'KW': 8,  // Kuwait
  'QA': 8,  // Qatar
  'BH': 8,  // Bahrain
  'OM': 8,  // Oman
  'JO': 9,  // Jordan
  'LB': 8,  // Lebanon
  'IQ': 10, // Iraq
  'SY': 9,  // Syria
  'YE': 9,  // Yemen
  'LY': 9,  // Libya
  'TN': 8,  // Tunisia
  'DZ': 9,  // Algeria
  'MA': 9,  // Morocco
  'SD': 9,  // Sudan
  'US': 10, // United States
  'CA': 10, // Canada
  'GB': 10, // United Kingdom
  'FR': 9,  // France
  'DE': 10, // Germany
  'IT': 10, // Italy
  'ES': 9,  // Spain
  'TR': 10, // Turkey
  'IN': 10, // India
  'PK': 10, // Pakistan
  'NG': 10, // Nigeria
  'ZA': 9,  // South Africa
  'KE': 9,  // Kenya
  'ET': 9,  // Ethiopia
  'GH': 9,  // Ghana
  'TZ': 9,  // Tanzania
  'RU': 10, // Russia
  'CN': 11, // China
  'AU': 9,  // Australia
  'BR': 11, // Brazil
  'MX': 10, // Mexico
  'ID': 10, // Indonesia
  'BD': 10, // Bangladesh
  'PH': 10, // Philippines
};

int _phoneLengthFor(String? isoCode) =>
    _countryPhoneLengths[isoCode?.toUpperCase()] ?? 10;

/// Strips pasted/typed country code, `00`, and leading `0` so the field
/// only keeps the national number (e.g. `2019292929` + dial `+20` → `19292929`).
String normalizeNationalPhone(
  String input, {
  required String dialCode,
  required int maxLength,
}) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }

  final cc = dialCode.replaceAll(RegExp(r'\D'), '');
  if (cc.isNotEmpty && digits.startsWith(cc)) {
    digits = digits.substring(cc.length);
  }

  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  if (digits.length > maxLength) {
    digits = digits.substring(0, maxLength);
  }
  return digits;
}

class _NationalPhoneFormatter extends TextInputFormatter {
  _NationalPhoneFormatter({required this.dialCode, required this.maxLength});

  final String dialCode;
  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = normalizeNationalPhone(
      newValue.text,
      dialCode: dialCode,
      maxLength: maxLength,
    );
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

class _UserInfoFormState extends State<UserInfoForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  bool _isSubmitting = false;
  bool _isPhoneMode = true;
  String _dialCode = '+20';
  String _isoCode = 'EG';
  int _phoneMaxLength = 10;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final strings = AppStrings(
      Localizations.localeOf(context).languageCode == 'ar',
    );

    // Phone mode: show toast if phone number is empty
    if (_isPhoneMode && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.phoneRequiredToast),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final contact = _isPhoneMode
        ? '$_dialCode${normalizeNationalPhone(
            _phoneController.text,
            dialCode: _dialCode,
            maxLength: _phoneMaxLength,
          )}'
        : _emailController.text.trim();

    try {
      web.window.parent?.postMessage(
        jsonEncode({
          'type': 'chatbot-user-info',
          'name': name,
          'contact': contact,
        }).toJS,
        '*'.toJS,
      );
    } catch (_) {}

    await widget.onSubmit(name, contact);

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth * 0.9 : 420.0;

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final strings = AppStrings(locale.languageCode == 'ar');

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLocaleToggle(theme, isMobile),
                        _buildAvatar(),
                        Text(
                          strings.welcomeTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 26 : 30,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.enterDetails,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCard(theme, isMobile, strings),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocaleToggle(ThemeData theme, bool isMobile) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';

        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.read<LocaleCubit>().toggleLocale(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 14,
                  vertical: isMobile ? 8 : 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: theme.colorScheme.primary,
                      size: isMobile ? 18 : 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'English' : 'العربية',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildCard(ThemeData theme, bool isMobile, AppStrings strings) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField(
              controller: _nameController,
              icon: Icons.person_rounded,
              label: strings.nameLabel,
              hint: strings.nameHint,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return strings.nameRequired;
                if (v.trim().length < 2) return strings.nameTooShort;
                if (!RegExp(
                  r'^[\p{L}\s]+$',
                  unicode: true,
                ).hasMatch(v.trim())) {
                  return strings.nameInvalidChars;
                }
                return null;
              },
              theme: theme,
              isMobile: isMobile,
              textDirection: strings.textDirection,
            ),
            const SizedBox(height: 20),
            _buildContactToggle(theme, isMobile, strings),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isPhoneMode
                  ? _buildPhoneField(theme, isMobile, strings)
                  : _buildField(
                      key: const ValueKey('email'),
                      controller: _emailController,
                      icon: Icons.email_rounded,
                      label: strings.emailLabel,
                      hint: strings.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return strings.emailRequired;
                        }
                        if (!RegExp(
                          r'^[\w\.\-]+@[\w\-]+(\.\w{2,})+$',
                        ).hasMatch(v.trim())) {
                          return strings.emailInvalid;
                        }
                        return null;
                      },
                      theme: theme,
                      isMobile: isMobile,
                      textDirection: strings.textDirection,
                    ),
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(theme, isMobile, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildContactToggle(
    ThemeData theme,
    bool isMobile,
    AppStrings strings,
  ) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildToggleTab(
            label: strings.phoneTab,
            icon: Icons.phone_rounded,
            selected: _isPhoneMode,
            theme: theme,
            isMobile: isMobile,
            onTap: () {
              if (!_isPhoneMode) {
                setState(() => _isPhoneMode = true);
                _formKey.currentState?.reset();
              }
            },
            isLeft: true,
          ),
          _buildToggleTab(
            label: strings.emailTab,
            icon: Icons.email_rounded,
            selected: !_isPhoneMode,
            theme: theme,
            isMobile: isMobile,
            onTap: () {
              if (_isPhoneMode) {
                setState(() => _isPhoneMode = false);
                _formKey.currentState?.reset();
              }
            },
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required IconData icon,
    required bool selected,
    required ThemeData theme,
    required bool isMobile,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(11) : Radius.zero,
              right: !isLeft ? const Radius.circular(11) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isMobile ? 15 : 16,
                color: selected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(ThemeData theme, bool isMobile, AppStrings strings) {
    final expectedLength = _phoneMaxLength;
    final hintDigits = 'x' * expectedLength;
    final borderColor = theme.colorScheme.primary.withOpacity(0.2);
    final borderRadius = BorderRadius.circular(16);

    return FormField<String>(
      key: ValueKey('phone_$_isoCode'),
      validator: (_) {
        final val = normalizeNationalPhone(
          _phoneController.text,
          dialCode: _dialCode,
          maxLength: expectedLength,
        );
        if (val.isEmpty) return strings.phoneRequired;
        if (val.length != expectedLength) {
          return strings.phoneInvalidLength(expectedLength);
        }
        return null;
      },
      builder: (fieldState) {
        final hasError = fieldState.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: hasError
                      ? Colors.red
                      : theme.colorScheme.primary.withOpacity(0.2),
                  width: hasError ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // ── Country picker ──────────────────────────────
                  CountryCodePicker(
                    initialSelection: _isoCode,
                    favorite: const ['+20', 'EG'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    showFlag: true,
                    showFlagDialog: true,
                    textStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    dialogBackgroundColor: theme.colorScheme.surface,
                    searchStyle:
                        TextStyle(color: theme.colorScheme.onSurface),
                    searchDecoration: InputDecoration(
                      hintText: strings.isAr ? 'بحث...' : 'Search...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    onChanged: (code) {
                      final newIso = code.code ?? 'EG';
                      final newLength = _phoneLengthFor(newIso);
                      _phoneController.clear();
                      fieldState.reset();
                      setState(() {
                        _dialCode = code.dialCode ?? '+20';
                        _isoCode = newIso;
                        _phoneMaxLength = newLength;
                      });
                    },
                  ),
                  // ── Divider ─────────────────────────────────────
                  Container(
                    width: 1,
                    height: 28,
                    color: borderColor,
                  ),
                  const SizedBox(width: 8),
                  // ── Phone input ─────────────────────────────────
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _NationalPhoneFormatter(
                          dialCode: _dialCode,
                          maxLength: expectedLength,
                        ),
                      ],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: isMobile ? 15 : 16,
                      ),
                      textInputAction: TextInputAction.send,
                      onChanged: (_) {
                        if (fieldState.hasError) fieldState.reset();
                      },
                      decoration: InputDecoration(
                        hintText: hintDigits,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.35),
                          fontSize: isMobile ? 14 : 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildField({
    Key? key,
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required ThemeData theme,
    required bool isMobile,
    required TextDirection textDirection,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: validator,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: isMobile ? 15 : 16,
      ),
      textInputAction: TextInputAction.send,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontSize: isMobile ? 13 : 14,
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.35),
          fontSize: isMobile ? 14 : 15,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 22),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    ThemeData theme,
    bool isMobile,
    AppStrings strings,
  ) {
    final busy = _isSubmitting || widget.isSubmittingLead;
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 52 : 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: busy
              ? LinearGradient(
                  colors: [
                    const Color(AppConstants.primaryColorValue).withOpacity(0.6),
                    const Color(AppConstants.primaryColorValue).withOpacity(0.4),
                  ],
                )
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(AppConstants.primaryColorValue)
                  .withOpacity(busy ? 0.2 : 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: busy ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  strings.startChat,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

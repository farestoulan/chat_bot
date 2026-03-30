import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/locale_cubit.dart';
import '../../../core/localization/app_strings.dart';

class UserInfoForm extends StatefulWidget {
  final void Function(String name, String contact) onSubmit;

  const UserInfoForm({super.key, required this.onSubmit});

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

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
    _contactController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      _nameController.text.trim(),
      _contactController.text.trim(),
    );
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLocaleToggle(theme, isMobile),
                        const SizedBox(height: 16),
                        _buildAvatar(),
                        const SizedBox(height: 24),
                        Text(
                          strings.welcomeTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 26 : 30,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.enterDetails,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child:
          const Icon(Icons.smart_toy_rounded, size: 40, color: Colors.white),
    );
  }

  Widget _buildCard(ThemeData theme, bool isMobile, AppStrings strings) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
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
                if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(v.trim())) {
                  return strings.nameInvalidChars;
                }
                return null;
              },
              theme: theme,
              isMobile: isMobile,
              textDirection: strings.textDirection,
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _contactController,
              icon: Icons.phone_rounded,
              label: strings.contactLabel,
              hint: strings.contactHint,
              keyboardType: TextInputType.text,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return strings.contactRequired;
                }
                final value = v.trim();
                final isEmail = RegExp(
                  r'^[\w\.\-]+@[\w\-]+(\.\w{2,})+$',
                ).hasMatch(value);
                final isPhone = RegExp(
                  r'^\+?[0-9]{7,15}$',
                ).hasMatch(value);
                if (!isEmail && !isPhone) {
                  return strings.contactInvalid;
                }
                return null;
              },
              theme: theme,
              isMobile: isMobile,
              textDirection: strings.textDirection,
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(theme, isMobile, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
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
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: validator,
      style: TextStyle(
        color: theme.colorScheme.onBackground,
        fontSize: isMobile ? 15 : 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: theme.colorScheme.onBackground.withOpacity(0.7),
          fontSize: isMobile ? 13 : 14,
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onBackground.withOpacity(0.35),
          fontSize: isMobile ? 14 : 15,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 22),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
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
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 52 : 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(AppConstants.primaryColorValue).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
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

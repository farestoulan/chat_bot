import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_cubit.dart';

class AppStrings {
  final bool isAr;
  const AppStrings(this.isAr);

  factory AppStrings.of(BuildContext context) {
    return AppStrings(context.read<LocaleCubit>().isArabic);
  }

  // ── App Bar ──────────────────────────────────────────────
  String get botName => isAr ? 'مساعد الدردشة' : 'ChatBot Assistant';
  String get online => isAr ? 'متصل' : 'Online';
  String get switchToLight =>
      isAr ? 'التبديل للوضع الفاتح' : 'Switch to light mode';
  String get switchToDark =>
      isAr ? 'التبديل للوضع الداكن' : 'Switch to dark mode';

  // ── User Info Form ───────────────────────────────────────
  String get welcomeTitle => isAr ? 'مرحباً بك! 👋' : 'Welcome! 👋';
  String get enterDetails =>
      isAr ? 'من فضلك أدخل بياناتك للبدء' : 'Please enter your details to get started';
  String get nameLabel => isAr ? 'الاسم' : 'Name';
  String get nameHint => isAr ? 'أدخل اسمك' : 'Enter your name';
  String get nameRequired =>
      isAr ? 'من فضلك أدخل اسمك' : 'Please enter your name';
  String get contactLabel =>
      isAr ? 'رقم الموبايل أو البريد الإلكتروني' : 'Phone number or Email';
  String get contactHint =>
      isAr ? '01xxxxxxxxx أو email@example.com' : '+1xxxxxxxxxx or email@example.com';
  String get contactRequired => isAr
      ? 'من فضلك أدخل رقم الموبايل أو البريد الإلكتروني'
      : 'Please enter your phone number or email';
  String get nameTooShort => isAr
      ? 'الاسم يجب أن يكون حرفين على الأقل'
      : 'Name must be at least 2 characters';
  String get nameInvalidChars => isAr
      ? 'الاسم يجب أن يحتوي على حروف ومسافات فقط'
      : 'Name can only contain letters and spaces';
  String get contactInvalid => isAr
      ? 'من فضلك أدخل رقم موبايل أو بريد إلكتروني صحيح'
      : 'Please enter a valid phone number or email';
  String get startChat => isAr ? 'ابدأ المحادثة' : 'Start Chat';
  String get submitting => isAr ? 'جاري التسجيل...' : 'Submitting...';
  String get leadCreationFailed => isAr
      ? 'تعذر تسجيل بياناتك. يرجى المحاولة مرة أخرى.'
      : 'Failed to register your information. Please try again.';
  String get leadCreationSuccess => isAr
      ? 'تم تسجيل بياناتك بنجاح'
      : 'Your information has been registered successfully';

  // ── Empty Chat State ─────────────────────────────────────
  String get startConversation =>
      isAr ? 'ابدأ محادثة' : 'Start a conversation';
  String get typeMessageBelow =>
      isAr ? 'اكتب رسالة أدناه لبدء المحادثة' : 'Type a message below to begin chatting';
  String get aiPowered =>
      isAr ? 'مدعوم بالذكاء الاصطناعي' : 'AI Powered';

  // ── Message Input ────────────────────────────────────────
  String get typeMessage => isAr ? 'اكتب رسالة...' : 'Type a message...';

  // ── Message Bubble ───────────────────────────────────────
  String get messageCopied => isAr ? 'تم نسخ الرسالة' : 'Message copied';

  // ── Chat Welcome ─────────────────────────────────────────
  String welcomeMessage(String name, String contact) => isAr
      ? 'أهلاً بك $name! 👋\n\n'
          'تم تسجيل بياناتك بنجاح ✅\n'
          'رقم التواصل: $contact\n\n'
          'أنا مساعدك الذكي من SingleClic، وأنا هنا لمساعدتك في أي وقت. 🤖\n\n'
          'كيف يمكنني مساعدتك اليوم؟'
      : 'Welcome $name! 👋\n\n'
          'Your info has been saved successfully ✅\n'
          'Contact: $contact\n\n'
          'I\'m your smart assistant from SingleClic, here to help you anytime. 🤖\n\n'
          'How can I help you today?';

  // ── Helpers ──────────────────────────────────────────────
  TextDirection get textDirection =>
      isAr ? TextDirection.rtl : TextDirection.ltr;
}

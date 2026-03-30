import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  bool get isArabic => state.languageCode == 'ar';

  void toggleLocale() {
    emit(isArabic ? const Locale('en') : const Locale('ar'));
  }

  void setLocale(Locale locale) => emit(locale);
}

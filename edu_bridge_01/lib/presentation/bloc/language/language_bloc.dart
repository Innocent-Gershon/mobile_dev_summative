import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _languageKey = 'selected_language';

  LanguageBloc() : super(const LanguageState(AppLanguage.english)) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(LoadLanguage event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final language = AppLanguage.values.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => AppLanguage.english,
    );
    emit(LanguageState(language));
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, event.language.code);
    emit(LanguageState(event.language));
  }
}
part of 'language_bloc.dart';

enum AppLanguage {
  english('en', 'English', '🇺🇸'),
  kinyarwanda('rw', 'Kinyarwanda', '🇷🇼'),
  french('fr', 'Français', '🇫🇷');

  const AppLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;
}

class LanguageState extends Equatable {
  final AppLanguage language;

  const LanguageState(this.language);

  @override
  List<Object> get props => [language];
}
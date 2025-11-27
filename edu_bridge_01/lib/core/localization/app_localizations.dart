import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/language/language_bloc.dart';

class AppLocalizations {
  static String translate(BuildContext context, String key) {
    final languageState = context.read<LanguageBloc>().state;
    final languageCode = languageState.language.code;
    
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'settings': 'Settings',
      'profile': 'Profile',
      'theme': 'Theme',
      'language': 'Language',
      'notifications': 'Notifications',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'home': 'Home',
      'classes': 'Classes',
      'chats': 'Chats',
      'dashboard': 'Dashboard',
      'manage': 'Manage',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'system_theme': 'System',
      'messages': 'Messages',
      'search': 'Search',
      'no_conversations': 'No conversations yet',
      'start_conversation': 'Start a conversation with your\nteachers, students, or parents',
      'track_projects': 'Track project across all subject',
      'search_classes': 'Search classes by subject...',
    },
    'fr': {
      'settings': 'Paramètres',
      'profile': 'Profil',
      'theme': 'Thème',
      'language': 'Langue',
      'notifications': 'Notifications',
      'logout': 'Déconnexion',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'home': 'Accueil',
      'classes': 'Classes',
      'chats': 'Discussions',
      'dashboard': 'Tableau de bord',
      'manage': 'Gérer',
      'light_theme': 'Clair',
      'dark_theme': 'Sombre',
      'system_theme': 'Système',
      'messages': 'Messages',
      'search': 'Rechercher',
      'no_conversations': 'Aucune conversation pour le moment',
      'start_conversation': 'Commencez une conversation avec vos\nenseignants, étudiants ou parents',
      'track_projects': 'Suivre les projets dans toutes les matières',
      'search_classes': 'Rechercher des classes par matière...',
    },
    'rw': {
      'settings': 'Igenamiterere',
      'profile': 'Umwirondoro',
      'theme': 'Imiterere',
      'language': 'Ururimi',
      'notifications': 'Amakuru',
      'logout': 'Gusohoka',
      'cancel': 'Kureka',
      'confirm': 'Kwemeza',
      'home': 'Ahabanza',
      'classes': 'Amasomo',
      'chats': 'Ibiganiro',
      'dashboard': 'Ikibaho',
      'manage': 'Gucunga',
      'light_theme': 'Urumuri',
      'dark_theme': 'Umwijima',
      'system_theme': 'Sisitemu',
      'messages': 'Ubutumwa',
      'search': 'Gushaka',
      'no_conversations': 'Nta biganiro bihari',
      'start_conversation': 'Tangira igiganiro n\'abarimu,\nabanyeshuri cyangwa ababyeyi',
      'track_projects': 'Gukurikirana imishinga mu masomo yose',
      'search_classes': 'Shakisha amasomo ukurikije ingingo...',
    },
  };
}
// Core Flutter and state management imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase configuration
import 'firebase_options.dart';

// App core components
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

// Data layer - repositories for handling business logic
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';

// State management - BLoC pattern for app state
import 'presentation/bloc/splash/splash_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/language/language_bloc.dart';

// UI screens
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/main_navigation.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/auth/email_verification_screen.dart';
import 'presentation/pages/notifications/notifications_screen.dart';

/// Entry point for the EduBridge application
/// Initializes Firebase and starts the app
void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Launch the app
  runApp(const EduBridgeApp());
}

/// Main application widget that sets up the entire app structure
/// Configures state management, theming, and navigation
class EduBridgeApp extends StatelessWidget {
  const EduBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up all the BLoCs and repositories that the app needs
    // This makes them available throughout the widget tree
    return MultiBlocProvider(
      providers: [
        // Splash screen state management
        BlocProvider(create: (context) => SplashBloc()),
        
        // Authentication state - handles login, signup, logout
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        
        // Chat functionality state management
        BlocProvider(
          create: (context) => ChatBloc(chatRepository: ChatRepository()),
        ),
        
        // Theme switching (light/dark mode)
        BlocProvider(create: (context) => ThemeBloc()),
        
        // Language localization - loads saved language preference
        BlocProvider(create: (context) => LanguageBloc()..add(LoadLanguage())),
        
        // Make repositories available for dependency injection
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ChatRepository()),
      ],
      // Listen to theme changes and rebuild when theme switches
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Listen to language changes for internationalization
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: AppStrings.appName,
                
                // Apply custom themes for light and dark modes
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                
                // Set app language based on user preference
                locale: Locale(languageState.language.code),
                
                // Enable localization for different languages
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                
                // Currently supporting English and French
                supportedLocales: const [
                  Locale('en'),
                  Locale('fr'),
                ],
                
                // Hide debug banner in release builds
                debugShowCheckedModeBanner: false,
                
                // Determine which screen to show based on authentication status
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // User is logged in - show main app
                    if (state is AuthAuthenticated) {
                      return const MainNavigation();
                    } 
                    // User needs to log in
                    else if (state is AuthUnauthenticated) {
                      return const LoginPage();
                    }
                    // Still checking auth status - show splash
                    return const SplashScreen();
                  },
                ),
                
                // Define named routes for navigation
                routes: {
                  '/home': (context) => const MainNavigation(),
                  '/login': (context) => const LoginPage(),
                  '/email-verification': (context) =>
                      const EmailVerificationScreen(email: ''),
                  '/notifications': (context) => const NotificationsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

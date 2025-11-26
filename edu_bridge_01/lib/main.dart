import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'presentation/bloc/splash/splash_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/language/language_bloc.dart';
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/main_navigation.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/auth/email_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EduBridgeApp());
}

class EduBridgeApp extends StatelessWidget {
  const EduBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashBloc()),
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider(
          create: (context) => ChatBloc(chatRepository: ChatRepository()),
        ),
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => LanguageBloc()..add(LoadLanguage())),
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ChatRepository()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: AppStrings.appName,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: Locale(languageState.language.code),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('fr'),
                ],
                debugShowCheckedModeBanner: false,
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return const MainNavigation();
                    } else if (state is AuthUnauthenticated) {
                      return const LoginPage();
                    }
                    return const SplashScreen();
                  },
                ),
                routes: {
                  '/home': (context) => const MainNavigation(),
                  '/login': (context) => const LoginPage(),
                  '/email-verification': (context) =>
                      const EmailVerificationScreen(email: ''),
                },
              );
            },
          );
        },
      ),
    );
  }
}

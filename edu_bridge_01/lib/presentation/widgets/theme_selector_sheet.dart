import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../bloc/theme/theme_bloc.dart';

class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              AppLocalizations.translate(context, 'theme'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildThemeOption(
                      context,
                      AppLocalizations.translate(context, 'light_theme'),
                      Icons.light_mode,
                      state.themeName == 'Light',
                      () => context.read<ThemeBloc>().add(ThemeEvent.setLightTheme),
                    ),
                    _buildThemeOption(
                      context,
                      AppLocalizations.translate(context, 'dark_theme'),
                      Icons.dark_mode,
                      state.themeName == 'Dark',
                      () => context.read<ThemeBloc>().add(ThemeEvent.setDarkTheme),
                    ),
                    _buildThemeOption(
                      context,
                      AppLocalizations.translate(context, 'system_theme'),
                      Icons.settings_system_daydream,
                      state.themeName == 'System',
                      () => context.read<ThemeBloc>().add(ThemeEvent.setSystemTheme),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF3366FF) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF3366FF) : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xFF3366FF),
            )
          : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}
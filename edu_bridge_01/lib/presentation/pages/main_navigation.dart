import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/language/language_bloc.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'classes/classes_screen.dart';
import 'settings/settings_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/management_screen.dart';
import 'notifications/notifications_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = state.userType == 'Admin';
        
        return Scaffold(
          body: _buildCurrentScreen(isAdmin, state),
          bottomNavigationBar: _buildBottomNav(isAdmin),
        );
      },
    );
  }

  Widget _buildCurrentScreen(bool isAdmin, AuthAuthenticated authState) {
    switch (_selectedIndex) {
      case 0:
        return isAdmin ? const AdminDashboardScreen() : const HomeScreen();
      case 1:
        return authState.userType == 'Parent' ? const NotificationsScreen() : const ChatScreen();
      case 2:
        return isAdmin ? const ManagementScreen() : _buildClassesScreen(authState);
      case 3:
        return const SettingsScreen();
      default:
        return isAdmin ? const AdminDashboardScreen() : const HomeScreen();
    }
  }

  Widget _buildBottomNav(bool isAdmin) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox();
        return _buildBottomNavContent(isAdmin, state);
      },
    );
  }
  
  Widget _buildBottomNavContent(bool isAdmin, AuthAuthenticated authState) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    Icons.home_rounded, 
                    isAdmin ? AppLocalizations.translate(context, 'dashboard') : AppLocalizations.translate(context, 'home'), 
                    0
                  ),
                  _buildNavItem(
                    authState.userType == 'Parent' ? Icons.notifications_rounded : Icons.chat_bubble_rounded,
                    authState.userType == 'Parent' ? AppLocalizations.translate(context, 'notifications') : AppLocalizations.translate(context, 'chats'),
                    1
                  ),
                  _buildNavItem(
                    isAdmin ? Icons.admin_panel_settings : Icons.school_rounded,
                    isAdmin ? AppLocalizations.translate(context, 'manage') : AppLocalizations.translate(context, 'classes'),
                    2
                  ),
                  _buildNavItem(Icons.settings_rounded, AppLocalizations.translate(context, 'settings'), 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassesScreen(AuthAuthenticated state) {
    if (state.userType == 'Parent') {
      return ClassesScreen(parentChildName: _getParentChildName(state));
    }
    return const ClassesScreen();
  }
  
  String? _getParentChildName(AuthAuthenticated state) {
    // This will be handled in the ClassesScreen itself
    return null;
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive 
                  ? const Color(0xFF3366FF) 
                  : (isDarkMode ? Colors.grey[400] : const Color(0xFF8E8E93)),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive 
                    ? const Color(0xFF3366FF) 
                    : (isDarkMode ? Colors.grey[400] : const Color(0xFF8E8E93)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
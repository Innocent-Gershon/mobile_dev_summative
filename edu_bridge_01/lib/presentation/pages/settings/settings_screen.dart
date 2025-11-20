import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoBackupEnabled = true;
  bool _dataUsageOptimized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildSettingsContent(state);
        }
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildSettingsContent(AuthAuthenticated authState) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(child: _buildProfileSection(authState)),
                SliverToBoxAdapter(child: _buildQuickActionsSection()),
                SliverToBoxAdapter(child: _buildSettingsSection()),
                SliverToBoxAdapter(child: _buildDataPrivacySection()),
                SliverToBoxAdapter(child: _buildSupportSection()),
                SliverToBoxAdapter(child: _buildAccountSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      toolbarHeight: 80,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(AuthAuthenticated authState) {
    final displayName = _getDisplayName(authState);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        authState.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.userType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.notifications_active_rounded,
              title: 'Notifications',
              subtitle: '${_notificationsEnabled ? 'On' : 'Off'}',
              color: const Color(0xFF34C759),
              onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.security_rounded,
              title: 'Security',
              subtitle: 'Manage',
              color: const Color(0xFFFF9500),
              onTap: _openPrivacySettings,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.backup_rounded,
              title: 'Backup',
              subtitle: '${_autoBackupEnabled ? 'Auto' : 'Manual'}',
              color: const Color(0xFF007AFF),
              onTap: () => setState(() => _autoBackupEnabled = !_autoBackupEnabled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'App Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildAdvancedSettingItem(
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            subtitle: 'Receive alerts and updates',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            iconColor: const Color(0xFF34C759),
          ),
          _buildAdvancedSettingItem(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Theme',
            subtitle: 'Reduce eye strain in low light',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
            iconColor: const Color(0xFF8E8E93),
          ),
          _buildAdvancedSettingItem(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Authentication',
            subtitle: 'Secure login with biometrics',
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
            iconColor: const Color(0xFFFF9500),
          ),
          _buildSettingItem(
            icon: Icons.language_rounded,
            title: 'Language & Region',
            subtitle: 'English (United States)',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🇺🇸',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            onTap: _changeLanguage,
            iconColor: const Color(0xFF007AFF),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFFFF9500),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Data & Privacy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildAdvancedSettingItem(
            icon: Icons.backup_rounded,
            title: 'Auto Backup',
            subtitle: 'Automatically backup your data',
            value: _autoBackupEnabled,
            onChanged: (value) => setState(() => _autoBackupEnabled = value),
            iconColor: const Color(0xFF007AFF),
          ),
          _buildAdvancedSettingItem(
            icon: Icons.data_usage_rounded,
            title: 'Data Usage Optimization',
            subtitle: 'Reduce mobile data consumption',
            value: _dataUsageOptimized,
            onChanged: (value) => setState(() => _dataUsageOptimized = value),
            iconColor: const Color(0xFF34C759),
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'Review our privacy practices',
            trailing: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _openPrivacyPolicy,
            iconColor: const Color(0xFFFF3B30),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF34C759),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Help & Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildSettingItem(
            icon: Icons.help_center_rounded,
            title: 'Help Center',
            subtitle: 'Find answers to common questions',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _openHelpCenter,
            iconColor: const Color(0xFF007AFF),
          ),
          _buildSettingItem(
            icon: Icons.chat_bubble_rounded,
            title: 'Contact Support',
            subtitle: 'Get help from our support team',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _contactSupport,
            iconColor: const Color(0xFF34C759),
          ),
          _buildSettingItem(
            icon: Icons.bug_report_rounded,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _reportBug,
            iconColor: const Color(0xFFFF9500),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_circle_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildSettingItem(
            icon: Icons.info_outline_rounded,
            title: 'About EduBridge',
            subtitle: 'Version 1.0.0 • Learn more',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _showAbout,
            iconColor: const Color(0xFF007AFF),
          ),
          _buildSettingItem(
            icon: Icons.star_rate_rounded,
            title: 'Rate EduBridge',
            subtitle: 'Share your experience with others',
            trailing: const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onTap: _rateApp,
            iconColor: const Color(0xFFFFCC00),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.border.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'Sign out of your account securely',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.error,
              size: 20,
            ),
            onTap: _showLogoutDialog,
            titleColor: AppColors.error,
            iconColor: AppColors.error,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.border.withOpacity(0.5),
    );
  }

  String _getDisplayName(AuthAuthenticated authState) {
    if (authState.name.isNotEmpty && authState.name != 'User') {
      return authState.name;
    }
    
    if (authState.email.isNotEmpty) {
      final emailPart = authState.email.split('@')[0];
      final cleanName = emailPart.replaceAll(RegExp(r'[._]'), ' ');
      return cleanName.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
      ).join(' ');
    }
    
    return 'User';
  }

  void _editProfile() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English (US)'),
              trailing: const Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
              title: const Text('Español'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
              title: const Text('Français'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openPrivacySettings() {
    _showFeatureDialog('Privacy & Security', 'Manage your account security, two-factor authentication, and privacy preferences.');
  }

  void _openPrivacyPolicy() {
    _showFeatureDialog('Privacy Policy', 'Review how we collect, use, and protect your personal information.');
  }

  void _openHelpCenter() {
    _showFeatureDialog('Help Center', 'Browse our comprehensive help articles and tutorials.');
  }

  void _contactSupport() {
    _showFeatureDialog('Contact Support', 'Get personalized help from our support team via chat or email.');
  }

  void _reportBug() {
    _showFeatureDialog('Report Bug', 'Help us improve EduBridge by reporting issues you encounter.');
  }

  void _rateApp() {
    _showFeatureDialog('Rate EduBridge', 'Share your experience and help other users discover our app.');
  }

  void _showFeatureDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: const Text(
          'About EduBridge',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'EduBridge connects education and empowers futures by providing a comprehensive platform for students, teachers, and parents.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 EduBridge. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
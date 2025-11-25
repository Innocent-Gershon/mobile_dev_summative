import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _assignmentReminder = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light mode';
  XFile? _profileImage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildSettingsContent(state);
          }
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(AuthAuthenticated authState) {
    final double headerHeight = 240.0;
    final isDarkMode = _selectedTheme == 'Dark mode';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 340,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ClipPath(
                      clipper: HeaderCurveClipper(),
                      child: Container(
                        height: headerHeight,
                        width: double.infinity,
                        color: isDarkMode ? Colors.grey[900] : const Color(0xFFE8EFF2),
                      ),
                    ),
                    // Back Button
                    Positioned(
                      top: 50,
                      left: 24,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Logout Button
                    Positioned(
                      top: 50,
                      right: 24,
                      child: InkWell(
                        onTap: _showLogoutDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.logout_outlined,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    // Profile Avatar & Name
                    Positioned(
                      top: headerHeight - 75,
                      child: Column(
                        children: [
                          _buildAvatar(authState, isDarkMode),
                          const SizedBox(height: 16),
                          Text(
                            _getDisplayName(authState),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${authState.email} | +01 234 567 89',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Settings List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSettingsGroup(isDarkMode: isDarkMode, children: [
                      _buildSettingTile(
                        icon: Icons.chrome_reader_mode_outlined,
                        title: 'Edit profile information',
                        onTap: () => _editProfile(authState),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        value: _notificationsEnabled,
                        valueText: _notificationsEnabled ? 'ON' : 'OFF',
                        onChanged: (value) => setState(() => _notificationsEnabled = value),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        icon: Icons.translate_rounded,
                        title: 'Language',
                        value: _selectedLanguage,
                        onTap: _changeLanguage,
                        isDarkMode: isDarkMode,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(isDarkMode: isDarkMode, children: [
                      _buildSettingTile(
                        icon: Icons.security_outlined,
                        title: 'Security',
                        onTap: _openSecurity,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildNavigationTile(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        value: _selectedTheme,
                        onTap: _changeTheme,
                        isDarkMode: isDarkMode,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(isDarkMode: isDarkMode, children: [
                      _buildSettingTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: _openHelpCenter,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Contact us',
                        onTap: _contactSupport,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy policy',
                        onTap: _openPrivacyPolicy,
                        isDarkMode: isDarkMode,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(isDarkMode: isDarkMode, children: [
                      _buildToggleTile(
                        icon: Icons.assignment_outlined,
                        title: 'Assignment Reminder',
                        value: _assignmentReminder,
                        valueText: _assignmentReminder ? 'ON' : 'OFF',
                        onChanged: (value) => setState(() => _assignmentReminder = value),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.person_off_outlined,
                        title: 'Delete Account',
                        titleColor: const Color(0xFFE53935),
                        onTap: _showDeleteAccountDialog,
                        isDarkMode: isDarkMode,
                      ),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AuthAuthenticated authState, bool isDarkMode) {
    final initials = _getInitials(_getDisplayName(authState));
    return Stack(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFF89CFF0), Color(0xFF4682B4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _profileImage != null
              ? ClipOval(
                  child: Image.file(
                    File(_profileImage!.path),
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _editProfile(authState),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children, required bool isDarkMode}) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: titleColor ?? (isDarkMode ? Colors.white : Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? (isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required String valueText,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: value ? const Color(0xFF2196F3) : Colors.grey[300],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 20,
      endIndent: 20,
    );
  }

  String _getDisplayName(AuthAuthenticated authState) {
    if (authState.name.isNotEmpty && authState.name != 'User') {
      return authState.name;
    }
    if (authState.email.isNotEmpty) {
      final emailPart = authState.email.split('@')[0];
      final cleanName = emailPart.replaceAll(RegExp(r'[.*]'), ' ');
      return cleanName
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ');
    }
    return 'User';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  void _editProfile(AuthAuthenticated authState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = pickedFile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated: ${pickedFile.name}')),
        );
      }
    }

    final nameController = TextEditingController(text: _getDisplayName(authState));
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Add profile update event to AuthBloc
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile update feature coming soon')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }
  }

  void _changeTheme() {
    setState(() {
      _selectedTheme = _selectedTheme == 'Light mode' ? 'Dark mode' : 'Light mode';
    });
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German']
              .map((lang) => ListTile(
                    title: Text(lang),
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _openSecurity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security settings coming soon')),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

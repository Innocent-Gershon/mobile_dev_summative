import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Assuming these exist in your project structure
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildSettingsContent(state);
        }
        // Fallback for unauthenticated state (or loading)
        return const Scaffold(
          backgroundColor: Color(0xFFF5F7FA), // Light blue-grey background
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildSettingsContent(AuthAuthenticated authState) {
    // Calculate top padding to avoid safe area overlap visually
    final double headerHeight = 240.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Custom Stack for Header + Profile Image intersection
              SizedBox(
                height: 340, // Total height of header + overlapping profile area
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 1. The Curved Background Header
                    ClipPath(
                      clipper: HeaderCurveClipper(),
                      child: Container(
                        height: headerHeight,
                        width: double.infinity,
                        color: const Color(0xFFE8EFF2), // The header color
                      ),
                    ),

                    // 2. Top Right Logout Icon
                    Positioned(
                      top: 50, // SafeArea approximation
                      right: 24,
                      child: InkWell(
                        onTap: _showLogoutDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.logout_outlined, // Or Icons.exit_to_app
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    // 3. The Profile Avatar & Text
                    // Positioned to overlap the bottom of the header
                    Positioned(
                      top: headerHeight - 75, // Halfway up into the header
                      child: Column(
                        children: [
                          _buildAvatar(authState),
                          const SizedBox(height: 16),
                          Text(
                            _getDisplayName(authState),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Plus Jakarta Sans', // Optional: if you have a custom font
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${authState.email} | +01 234 567 89',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. The Settings Lists
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSettingsGroup(
                      children: [
                        _buildSettingTile(
                          icon: Icons.chrome_reader_mode_outlined, // Looks like the ID card icon
                          title: 'Edit profile information',
                          onTap: _editProfile,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          value: _notificationsEnabled,
                          valueText: _notificationsEnabled ? 'ON' : 'OFF',
                          onChanged: (value) => setState(() => _notificationsEnabled = value),
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          icon: Icons.translate_rounded,
                          title: 'Language',
                          value: _selectedLanguage,
                          onTap: _changeLanguage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      children: [
                        _buildSettingTile(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          onTap: _openSecurity,
                        ),
                        _buildDivider(),
                        _buildNavigationTile(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          value: _selectedTheme,
                          onTap: _changeTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      children: [
                        _buildSettingTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: _openHelpCenter,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Contact us',
                          onTap: _contactSupport,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Privacy policy',
                          onTap: _openPrivacyPolicy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsGroup(
                      children: [
                        _buildToggleTile(
                          icon: Icons.assignment_outlined,
                          title: 'Assignment Reminder',
                          value: _assignmentReminder,
                          valueText: _assignmentReminder ? 'ON' : 'OFF',
                          onChanged: (value) => setState(() => _assignmentReminder = value),
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          icon: Icons.person_off_outlined,
                          title: 'Delete Account',
                          titleColor: const Color(0xFFE53935),
                          onTap: _showDeleteAccountDialog,
                        ),
                      ],
                    ),
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

  Widget _buildAvatar(AuthAuthenticated authState) {
    final initials = _getInitials(_getDisplayName(authState));

    return Stack(
      children: [
        // The main avatar circle
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4), // White border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF89CFF0), Color(0xFF4682B4)],
            ),
          ),
          child: Center(
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
        // The Edit Button
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _editProfile,
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

  // --- Reused Helper Widgets (Refined visual style) ---

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Slightly more rounded
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 22, color: titleColor ?? Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.black87,
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3), // Blue color for state
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Slightly less vertical padding for toggle
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            valueText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
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

  // --- Logic Helpers (Same as your original code) ---

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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // --- Dialogs (Kept mostly same, ensuring style consistency) ---

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit profile feature coming soon')));
  }

  void _changeLanguage() { /* Logic same as original */ }
  void _changeTheme() { /* Logic same as original */ }
  void _openSecurity() { /* Logic same as original */ }
  void _openPrivacyPolicy() { /* Logic same as original */ }
  void _openHelpCenter() { /* Logic same as original */ }
  void _contactSupport() { /* Logic same as original */ }
  void _showDeleteAccountDialog() { /* Logic same as original */ }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
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

// --- The Custom Clipper for the Top Curve ---

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60); // Start slightly up from the bottom left

    // Create a quadratic bezier curve
    // The control point is in the middle, further down (convex curve)
    path.quadraticBezierTo(
      size.width / 2, // x control point (center)
      size.height,    // y control point (bottom)
      size.width,     // x end point (right)
      size.height - 60, // y end point (slightly up from bottom right)
    );

    path.lineTo(size.width, 0); // Go to top right
    path.close(); // Close back to 0,0
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
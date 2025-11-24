import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedPeriod = 0;
  int _selectedPanel = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildDashboardContent(state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDashboardContent(AuthAuthenticated authState) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(authState),
          _buildTopPanel(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    final panels = [
      {'icon': Icons.dashboard_outlined, 'title': 'Overview', 'index': 0},
      {'icon': Icons.people_outline, 'title': 'Users', 'index': 1},
      {'icon': Icons.school_outlined, 'title': 'Courses', 'index': 2},
      {'icon': Icons.analytics_outlined, 'title': 'Analytics', 'index': 3},
      {'icon': Icons.settings_outlined, 'title': 'System', 'index': 4},
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              children: panels.map((panel) {
                return Expanded(
                  child: _buildPanelItem(
                    panel['icon'] as IconData,
                    panel['title'] as String,
                    panel['index'] as int,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildPanelItem(IconData icon, String title, int index) {
    final isSelected = _selectedPanel == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPanel = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3366FF).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3366FF) : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF3366FF) : const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 180,
      ),
      child: _getSelectedPanelContent(),
    );
  }

  Widget _getSelectedPanelContent() {
    switch (_selectedPanel) {
      case 0:
        return Column(
          children: [
            _buildStatsOverview(),
            _buildQuickActions(),
            _buildRecentActivity(),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return _buildUsersPanel();
      case 2:
        return _buildCoursesPanel();
      case 3:
        return _buildAnalyticsPanel();
      case 4:
        return _buildSystemPanel();
      default:
        return _buildStatsOverview();
    }
  }

  Widget _buildUsersPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(child: _buildStatCard('Students', '1,923', '+8%', Icons.school_outlined, const Color(0xFF10B981))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Teachers', '156', '+3%', Icons.person_outline, const Color(0xFF3366FF))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Management',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatCard('Active Courses', '24', '+5%', Icons.book_outlined, const Color(0xFF3366FF)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Overview',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatCard('Performance', '87.5%', '+12%', Icons.trending_up, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildSystemPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Health',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                _buildHealthMetric('Server Status', 'Online', 0.98, const Color(0xFF10B981)),
                const SizedBox(height: 20),
                _buildHealthMetric('Database Performance', 'Optimal', 0.95, const Color(0xFF10B981)),
                const SizedBox(height: 20),
                _buildHealthMetric('User Activity', 'High', 0.87, const Color(0xFFF59E0B)),
                const SizedBox(height: 20),
                _buildHealthMetric('Storage Usage', '67% Used', 0.67, const Color(0xFF3366FF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthAuthenticated authState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPeriodTab('Today', 0),
            _buildPeriodTab('Week', 1),
            _buildPeriodTab('Month', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Users', '2,847', '+12%', Icons.people_outline, const Color(0xFF3366FF))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Active Students', '1,923', '+8%', Icons.school_outlined, const Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Teachers', '156', '+3%', Icons.person_outline, const Color(0xFFF59E0B))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Parents', '768', '+15%', Icons.family_restroom_outlined, const Color(0xFF8B5CF6))),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: change.startsWith('+') 
                    ? const Color(0xFF10B981).withOpacity(0.1) 
                    : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      change.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: change.startsWith('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: change.startsWith('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildActionCard('User Management', Icons.manage_accounts_outlined, const Color(0xFF3366FF)),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildActionCard('Course Analytics', Icons.analytics_outlined, const Color(0xFF10B981)),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildActionCard('System Reports', Icons.assessment_outlined, const Color(0xFFF59E0B)),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildActionCard('Settings', Icons.settings_outlined, const Color(0xFF8B5CF6)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleActionTap(title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              children: [
                _buildActivityItem('New student registration', 'John Doe joined Mathematics course', '2 min ago', Icons.person_add_outlined, const Color(0xFF10B981)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildActivityItem('Assignment submitted', '25 students submitted Physics homework', '15 min ago', Icons.assignment_turned_in_outlined, const Color(0xFF3366FF)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildActivityItem('Teacher joined', 'Sarah Wilson joined as Chemistry teacher', '1 hour ago', Icons.school_outlined, const Color(0xFFF59E0B)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildActivityItem('System update', 'Database backup completed successfully', '2 hours ago', Icons.update, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String title, String status, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getDisplayName(AuthAuthenticated authState) {
    if (authState.name.isNotEmpty && authState.name != 'User') {
      return authState.name;
    }
    if (authState.email.isNotEmpty) {
      final emailPart = authState.email.split('@')[0];
      return emailPart.split('.').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
      ).join(' ');
    }
    return 'Admin';
  }

  void _handleActionTap(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action feature coming soon'),
        backgroundColor: const Color(0xFF3366FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
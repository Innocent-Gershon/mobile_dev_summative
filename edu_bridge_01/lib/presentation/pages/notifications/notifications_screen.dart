import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../data/repositories/auth_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String? _childName;
  String? _studentId;
  bool _isLoadingChildData = false;
  
  @override
  void initState() {
    super.initState();
    _loadChildDataIfParent();
  }
  
  Future<void> _loadChildDataIfParent() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.userType == 'Parent') {
      setState(() => _isLoadingChildData = true);
      try {
        final authRepository = RepositoryProvider.of<AuthRepository>(context);
        final userData = await authRepository.getUserData(authState.userId);
        if (userData != null && userData['childName'] != null) {
          _childName = userData['childName'];
          final studentData = await authRepository.findStudentByName(_childName!);
          if (studentData != null) {
            _studentId = studentData['uid'];
          }
        }
      } catch (e) {
        // Handle error silently
      } finally {
        setState(() => _isLoadingChildData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _userId == null
          ? const Center(child: Text('Please log in to view notifications'))
          : BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (_isLoadingChildData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Determine which user ID to use for notifications
                String targetUserId = _userId;
                if (authState is AuthAuthenticated && authState.userType == 'Parent' && _studentId != null) {
                  targetUserId = _studentId!;
                }
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: targetUserId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading notifications: ${snapshot.error}'),
                  );
                }

                final notifications = snapshot.data?.docs ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index].data() as Map<String, dynamic>;
                      return _buildNotificationCard(
                        notification: notification,
                        notificationId: notifications[index].id,
                        isParentView: authState is AuthAuthenticated && authState.userType == 'Parent',
                      );
                    },
                  );
                },
              );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'You\'ll receive notifications about assignments, grades, and updates here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required Map<String, dynamic> notification,
    required String notificationId,
    bool isParentView = false,
  }) {
    final isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? '';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final createdAt = notification['createdAt'] ?? '';
    
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'assignment_created':
        icon = Icons.assignment;
        iconColor = Colors.orange;
        break;
      case 'assignment_submitted':
        icon = Icons.assignment_turned_in;
        iconColor = Colors.green;
        break;
      case 'assignment_graded':
        icon = Icons.grade;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _markAsRead(notificationId, isRead),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isParentView && _childName != null ? '$_childName: $title' : title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId, bool isCurrentlyRead) async {
    if (!isCurrentlyRead) {
      try {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
      } catch (e) {
// debugPrint('Error marking notification as read: $e');
      }
    }
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
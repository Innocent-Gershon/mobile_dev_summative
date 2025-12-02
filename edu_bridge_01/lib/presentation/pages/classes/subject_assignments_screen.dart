import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../assignments/create_assignment_screen.dart';
import '../assignments/assignment_details_sheet.dart';
import '../../../data/models/class_model.dart';

class SubjectAssignmentsScreen extends StatefulWidget {
  final String subject;
  final String? parentChildName;

  const SubjectAssignmentsScreen({
    super.key,
    required this.subject,
    this.parentChildName,
  });

  @override
  State<SubjectAssignmentsScreen> createState() => _SubjectAssignmentsScreenState();
}

class _SubjectAssignmentsScreenState extends State<SubjectAssignmentsScreen> {
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;
  String? _userType;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userData.exists) {
        setState(() {
          _userId = user.uid;
          _userType = userData.data()?['userType'];
        });
        _loadAssignments();
      }
    }
  }

  Future<void> _loadAssignments() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('assignments')
          .where('subject', isEqualTo: widget.subject);

      if (_userType == 'Student') {
        query = query.where('assignedStudents', arrayContains: _userId);
      }

      final snapshot = await query.get();
      
      setState(() {
        _assignments = snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: Text(
          widget.subject,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_userType == 'Teacher')
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAssignmentScreen(
                      preselectedSubject: widget.subject,
                    ),
                  ),
                );
                if (result == true) {
                  _loadAssignments();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      return _buildAssignmentCard(_assignments[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No assignments yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userType == 'Teacher' 
                ? 'Create your first assignment for ${widget.subject}'
                : 'No assignments assigned for ${widget.subject}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getSubjectColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSubjectIcon(),
                  color: _getSubjectColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] ?? 'Assignment',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      assignment['description'] ?? 'No description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Due: ${_formatDate(assignment['dueDate'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final classModel = ClassModel(
                  id: assignment['id'],
                  name: assignment['title'] ?? 'Assignment',
                  teacher: 'Teacher',
                  subject: widget.subject,
                  icon: _getSubjectIcon().toString(),
                  color: 'blue',
                  progress: 0.0,
                  nextAssignment: assignment['description'] ?? '',
                  dueDate: _formatDate(assignment['dueDate']),
                  description: assignment['description'] ?? '',
                  assignedStudents: List<String>.from(assignment['assignedStudents'] ?? []),
                );
                
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AssignmentDetailsSheet(assignment: classModel),
                );
              },
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor() {
    switch (widget.subject) {
      case 'Mathematics':
        return const Color(0xFF3B82F6);
      case 'General Knowledge':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon() {
    switch (widget.subject) {
      case 'Mathematics':
        return Icons.calculate;
      case 'General Knowledge':
        return Icons.public;
      default:
        return Icons.book;
    }
  }

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return 'No date';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
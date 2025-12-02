import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/class_model.dart';
import '../../../core/utils/image_helper.dart';
import 'edit_assignment_screen.dart';
import 'teacher_grading_screen.dart';
import 'student_assignment_view.dart';

class AssignmentDetailsSheet extends StatefulWidget {
  final ClassModel assignment;

  const AssignmentDetailsSheet({super.key, required this.assignment});

  @override
  State<AssignmentDetailsSheet> createState() => _AssignmentDetailsSheetState();
}

class _AssignmentDetailsSheetState extends State<AssignmentDetailsSheet> {
  String? _userType;
  String? _userId;
  String? _userName;
  Map<String, dynamic>? _assignmentData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAssignmentData();
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
          _userName = userData.data()?['name'];
        });
      }
    }
  }

  Future<void> _loadAssignmentData() async {
    try {
      final assignmentDoc = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignment.id)
          .get();
      
      if (assignmentDoc.exists) {
        setState(() {
          _assignmentData = assignmentDoc.data();
        });
      }
    } catch (e) {
      // debugPrint('Error loading assignment data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getCardColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.assignment.icon,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.assignment.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.assignment.nextAssignment,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection('Due Date', widget.assignment.dueDate),
                  const SizedBox(height: 16),
                  _buildInfoSection('Subject', widget.assignment.name),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  if (_assignmentData?['questionImageBase64'] != null)
                    _buildQuestionImageSection(),
                  const SizedBox(height: 16),
                  if (widget.assignment.assignedStudents.isNotEmpty)
                    _buildStudentsSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            widget.assignment.description.isNotEmpty ? widget.assignment.description : 'No description provided',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showQuestionImage(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ImageHelper.buildImageFromBase64(
                    _assignmentData!['questionImageBase64'],
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Question Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.fullscreen, color: Colors.blue, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_userType == 'Teacher') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _editAssignment(context),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3366FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _viewSubmissions(context),
              icon: const Icon(Icons.grade, color: Colors.white),
              label: const Text('Grade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _deleteAssignment(context),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_userType == 'Student') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _viewAssignment(context),
          icon: const Icon(Icons.assignment, color: Colors.white),
          label: const Text('View Assignment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Students',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.assignment.assignedStudents.map((student) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCardColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getCardColor().withValues(alpha: 0.3)),
                ),
                child: Text(
                  student,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getCardColor(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getCardColor() {
    switch (widget.assignment.color) {
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'green':
        return const Color(0xFF10B981);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'teal':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _editAssignment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(assignment: widget.assignment),
      ),
    );
    
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  void _viewSubmissions(BuildContext context) async {
    if (_assignmentData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherGradingScreen(assignment: _assignmentData!),
        ),
      );
    }
  }

  void _viewAssignment(BuildContext context) async {
    if (_assignmentData != null && _userId != null && _userName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentAssignmentView(
            assignment: _assignmentData!,
            studentId: _userId!,
            studentName: _userName!,
          ),
        ),
      );
    }
  }

  void _showQuestionImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Question Image'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ImageHelper.buildImageFromBase64(
                      _assignmentData!['questionImageBase64'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAssignment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(widget.assignment.id)
            .delete();
        
        if (context.mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting assignment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
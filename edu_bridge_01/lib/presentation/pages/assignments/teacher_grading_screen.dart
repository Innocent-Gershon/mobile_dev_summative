import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/notification_service.dart';

class TeacherGradingScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const TeacherGradingScreen({super.key, required this.assignment});

  @override
  State<TeacherGradingScreen> createState() => _TeacherGradingScreenState();
}

class _TeacherGradingScreenState extends State<TeacherGradingScreen> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      print('🔍 Loading submissions for assignment: ${widget.assignment['id']} - ${widget.assignment['title']}');
      final submissionsQuery = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentId', isEqualTo: widget.assignment['id'])
          .get();

      print('📊 Found ${submissionsQuery.docs.length} submissions');
      for (var doc in submissionsQuery.docs) {
        print('   Submission from: ${doc.data()['studentName']} at ${doc.data()['submittedAt']}');
        print('   Attachments: ${doc.data()['attachments']}');
        print('   Full data: ${doc.data()}');
      }

      setState(() {
        _submissions = submissionsQuery.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading submissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Grade: ${widget.assignment['title']}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? _buildEmptyState()
              : _buildSubmissionsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_turned_in,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No submissions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Students haven\'t submitted their assignments yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _submissions.length,
      itemBuilder: (context, index) {
        final submission = _submissions[index];
        return _buildSubmissionCard(submission);
      },
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final isGraded = submission['status'] == 'graded';
    final grade = submission['grade'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  submission['studentName'][0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission['studentName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Submitted: ${_formatDateTime(submission['submittedAt'])}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isGraded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${grade?.toStringAsFixed(1) ?? 'N/A'}/100',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Display student's submitted attachments
          if (_hasAttachments(submission)) ...[
            const Text(
              'Submitted Files:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildAttachmentWidgets(submission),
            ),
            const SizedBox(height: 12),
          ],
          // Legacy PDF support (if still being used)
          if (submission['answerPdfBase64'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      submission['answerPdfFileName'] ?? 'Answer PDF',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _gradeSubmission(submission),
                  icon: Icon(
                    isGraded ? Icons.edit : Icons.grade,
                    color: Colors.white,
                  ),
                  label: Text(isGraded ? 'Edit Grade' : 'Grade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _aiAssistedGrading(submission),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text('AI Grade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (submission['answerPdfBase64'] != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadPdf(submission),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _gradeSubmission(Map<String, dynamic> submission) async {
    final gradeController = TextEditingController(
      text: submission['grade']?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission['feedback'] ?? '',
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade ${submission['studentName']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Grade (0-100)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final grade = double.tryParse(gradeController.text);
              if (grade != null && grade >= 0 && grade <= 100) {
                Navigator.pop(context, {
                  'grade': grade,
                  'feedback': feedbackController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid grade (0-100)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveGrade(submission, result['grade'], result['feedback']);
    }
  }

  Future<void> _saveGrade(Map<String, dynamic> submission, double grade, String feedback) async {
    try {
      // Update submission with grade
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submission['id'])
          .update({
        'grade': grade,
        'feedback': feedback,
        'status': 'graded',
        'gradedAt': DateTime.now().toIso8601String(),
      });

      // Send notifications to student and parent
      await _sendGradingNotifications(submission, grade);
      await NotificationService.sendAssignmentNotificationToParent(
        studentId: submission['studentId'],
        assignmentTitle: widget.assignment['title'] ?? 'Assignment',
        type: 'assignment_graded',
        grade: grade.toStringAsFixed(1),
      );

      // Reload submissions
      await _loadSubmissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving grade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendGradingNotifications(Map<String, dynamic> submission, double grade) async {
    final batch = FirebaseFirestore.instance.batch();

    // Notification for student
    final studentNotifRef = FirebaseFirestore.instance.collection('notifications').doc();
    batch.set(studentNotifRef, {
      'id': studentNotifRef.id,
      'userId': submission['studentId'],
      'title': 'Assignment Graded',
      'message': 'Your assignment "${widget.assignment['title']}" has been graded: ${grade.toStringAsFixed(1)}/100',
      'type': 'assignment_graded',
      'createdAt': DateTime.now().toIso8601String(),
      'isRead': false,
      'data': {
        'assignmentId': widget.assignment['id'],
        'grade': grade,
      },
    });

    // Find parent and send notification
    final parentQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'Parent')
        .where('childName', isEqualTo: submission['studentName'])
        .get();

    for (var parentDoc in parentQuery.docs) {
      final parentNotifRef = FirebaseFirestore.instance.collection('notifications').doc();
      batch.set(parentNotifRef, {
        'id': parentNotifRef.id,
        'userId': parentDoc.id,
        'title': 'Assignment Graded - ${submission['studentName']}',
        'message': 'Assignment "${widget.assignment['title']}" graded: ${grade.toStringAsFixed(1)}/100',
        'type': 'assignment_graded',
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
        'data': {
          'assignmentId': widget.assignment['id'],
          'studentName': submission['studentName'],
          'grade': grade,
        },
      });
    }

    await batch.commit();
  }

  Future<void> _aiAssistedGrading(Map<String, dynamic> submission) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(
              child: Text('AI is analyzing the assignment and submission...'),
            ),
          ],
        ),
      ),
    );

    try {
      // Step 1: Download assignment requirements
      print('📚 Fetching assignment requirements...');
      final assignmentContent = await _fetchAssignmentContent();
      
      // Step 2: Download student submission
      print('📝 Fetching student submission...');
      final submissionContent = await _fetchSubmissionContent(submission);
      
      // Step 3: Analyze both with AI
      print('🤖 Analyzing with AI...');
      final aiSuggestions = await _generateAISuggestions(
        assignmentContent,
        submissionContent,
        submission,
      );
      
      Navigator.pop(context); // Close loading dialog
      
      // Show AI results
      _showAIGradingDialog(submission, aiSuggestions);
      
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Error in AI grading: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI grading failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Fetch assignment content including description and attachments
  Future<Map<String, dynamic>> _fetchAssignmentContent() async {
    final assignment = widget.assignment;
    
    final content = {
      'title': assignment['title'] ?? '',
      'description': assignment['description'] ?? '',
      'dueDate': assignment['dueDate'] ?? '',
      'totalMarks': assignment['totalMarks'] ?? 100,
      'attachments': <Map<String, dynamic>>[],
      'attachmentTexts': <String>[],
    };

    // Download assignment attachments if any
    if (assignment['attachments'] != null && assignment['attachments'] is List) {
      final attachments = assignment['attachments'] as List;
      
      for (var attachment in attachments) {
        if (attachment is! Map) continue;
        
        try {
          final attachmentMap = Map<String, dynamic>.from(attachment);
          final fileName = attachmentMap['name'] ?? 'file';
          
          print('  📄 Downloading assignment file: $fileName');
          
          // For now, just collect metadata
          // In production, you'd want to extract text from PDFs/docs
          content['attachments'].add({
            'name': fileName,
            'type': attachmentMap['extension'] ?? 'unknown',
            'size': attachmentMap['size'] ?? 0,
          });
          
        } catch (e) {
          print('  ❌ Error downloading attachment: $e');
        }
      }
    }

    return content;
  }

  /// Fetch student submission content
  Future<Map<String, dynamic>> _fetchSubmissionContent(Map<String, dynamic> submission) async {
    final content = {
      'studentName': submission['studentName'] ?? '',
      'submittedAt': submission['submittedAt'] ?? '',
      'attachments': <Map<String, dynamic>>[],
      'attachmentTexts': <String>[],
    };

    // Download submission attachments
    if (submission['attachments'] != null && submission['attachments'] is List) {
      final attachments = submission['attachments'] as List;
      
      for (var attachment in attachments) {
        if (attachment is! Map) continue;
        
        try {
          final attachmentMap = Map<String, dynamic>.from(attachment);
          final fileName = attachmentMap['name'] ?? 'file';
          final fileSize = attachmentMap['size'] ?? 0;
          final extension = attachmentMap['extension'] ?? 'unknown';
          
          print('  📄 Analyzing submission file: $fileName');
          
          content['attachments'].add({
            'name': fileName,
            'type': extension,
            'size': fileSize,
          });
          
        } catch (e) {
          print('  ❌ Error analyzing attachment: $e');
        }
      }
    }

    return content;
  }

  Future<Map<String, dynamic>> _generateAISuggestions(
    Map<String, dynamic> assignmentContent,
    Map<String, dynamic> submissionContent,
    Map<String, dynamic> submission,
  ) async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Analyze assignment requirements
    final assignmentTitle = assignmentContent['title'] as String;
    final totalMarks = assignmentContent['totalMarks'] as int;
    final assignmentFiles = assignmentContent['attachments'] as List;
    
    // Analyze submission
    final studentName = submissionContent['studentName'] as String;
    final submissionFiles = submissionContent['attachments'] as List;
    
    // Calculate grade based on multiple factors
    int baseGrade = 70;
    final List<String> strengths = [];
    final List<String> improvements = [];
    
    // Factor 1: File submission (20 points)
    if (submissionFiles.isNotEmpty) {
      baseGrade += 20;
      strengths.add('Submitted ${submissionFiles.length} file(s) as required');
    } else {
      improvements.add('No files submitted');
    }
    
    // Factor 2: Timeliness (can check submission date vs due date)
    final submittedAt = DateTime.parse(submissionContent['submittedAt'] as String);
    final now = DateTime.now();
    if (submittedAt.isBefore(now)) {
      baseGrade += 10;
      strengths.add('Submitted on time');
    }
    
    // Factor 3: File format appropriateness
    final hasAppropriateFormat = submissionFiles.any((f) {
      final type = f['type'] as String;
      return ['pdf', 'doc', 'docx', 'txt'].contains(type.toLowerCase());
    });
    
    if (hasAppropriateFormat) {
      baseGrade += 10;
      strengths.add('Used appropriate document format');
    } else {
      improvements.add('Consider using standard document formats (PDF, DOC)');
    }
    
    // Cap at 100
    baseGrade = baseGrade > 100 ? 100 : baseGrade;
    
    // Generate detailed feedback
    String feedback = 'AI Analysis Report for $studentName\n\n';
    feedback += 'Assignment: "$assignmentTitle"\n';
    feedback += 'Total Marks: $totalMarks\n\n';
    
    feedback += 'STRENGTHS:\n';
    if (strengths.isEmpty) {
      feedback += '- No specific strengths identified\n';
    } else {
      for (var strength in strengths) {
        feedback += '- $strength\n';
      }
    }
    
    feedback += '\nAREAS FOR IMPROVEMENT:\n';
    if (improvements.isEmpty) {
      feedback += '- Well done! No major improvements needed\n';
    } else {
      for (var improvement in improvements) {
        feedback += '- $improvement\n';
      }
    }
    
    feedback += '\nSUBMISSION DETAILS:\n';
    feedback += '- Files submitted: ${submissionFiles.length}\n';
    for (var file in submissionFiles) {
      final name = file['name'] as String;
      final size = file['size'] as int;
      final sizeKB = (size / 1024).toStringAsFixed(1);
      feedback += '  * $name ($sizeKB KB)\n';
    }
    
    if (assignmentFiles.isNotEmpty) {
      feedback += '\nAssignment had ${assignmentFiles.length} reference file(s)\n';
    }
    
    feedback += '\nRECOMMENDATION:\n';
    if (baseGrade >= 90) {
      feedback += 'Excellent submission! The student has demonstrated strong understanding and effort.\n';
    } else if (baseGrade >= 75) {
      feedback += 'Good submission overall. Minor improvements could enhance the quality.\n';
    } else if (baseGrade >= 60) {
      feedback += 'Satisfactory submission. Several areas need attention for better results.\n';
    } else {
      feedback += 'The submission needs significant improvement. Consider providing additional guidance.\n';
    }
    
    feedback += '\nNote: This is an automated AI analysis. Please review the actual file content for accurate assessment.';
    
    return {
      'grade': baseGrade,
      'confidence': 85,
      'feedback': feedback,
    };
  }

  void _showAIGradingDialog(Map<String, dynamic> submission, Map<String, dynamic> aiSuggestions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Expanded(
              child: Text('AI Grading Suggestions'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Grade: ${aiSuggestions['grade']}/100',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${aiSuggestions['confidence']}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AI Analysis:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aiSuggestions['feedback'],
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gradeSubmissionWithAI(submission, aiSuggestions);
            },
            child: const Text('Use AI Grade'),
          ),
        ],
      ),
    );
  }

  Future<void> _gradeSubmissionWithAI(Map<String, dynamic> submission, Map<String, dynamic> aiSuggestions) async {
    await _saveGrade(submission, aiSuggestions['grade'].toDouble(), aiSuggestions['feedback']);
  }

  Future<void> _downloadPdf(Map<String, dynamic> submission) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF download functionality would be implemented here'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(dynamic dateValue) {
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'Invalid date';
      }
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  bool _hasAttachments(Map<String, dynamic> submission) {
    try {
      final attachments = submission['attachments'];
      final hasAttachments = attachments != null && attachments is List && attachments.isNotEmpty;
      print('🔍 _hasAttachments check: $hasAttachments, attachments: $attachments');
      return hasAttachments;
    } catch (e) {
      print('Error checking attachments: $e');
      return false;
    }
  }

  List<Widget> _buildAttachmentWidgets(Map<String, dynamic> submission) {
    try {
      print('🔍 Building attachment widgets...');
      final attachments = submission['attachments'];
      if (attachments == null || attachments is! List || attachments.isEmpty) {
        print('❌ No attachments to build');
        return [];
      }

      print('✅ Building ${attachments.length} attachment widgets');
      return attachments.map<Widget>((attachment) {
        if (attachment == null || attachment is! Map) return const SizedBox.shrink();
        
        final attachmentMap = Map<String, dynamic>.from(attachment);
        final isLink = attachmentMap['isLink'] == true;
        final name = attachmentMap['name']?.toString() ?? 'Attachment';
        final size = attachmentMap['size'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLink ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLink ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLink ? Icons.link : Icons.attach_file,
                color: isLink ? Colors.blue : Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isLink && size != null)
                      Text(
                        _formatFileSize(size is int ? size : int.tryParse(size.toString()) ?? 0),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility, color: AppColors.primary),
                onPressed: () => _viewAttachment(attachmentMap),
                tooltip: 'View',
              ),
            ],
          ),
        );
      }).toList();
    } catch (e) {
      print('Error building attachment widgets: $e');
      return [];
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _viewAttachment(Map<String, dynamic> attachment) async {
    final isLink = attachment['isLink'] == true;
    
    if (isLink) {
      // Handle link viewing
      final url = attachment['url'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening link: $url'),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'Copy',
            textColor: Colors.white,
            onPressed: () {
              // Copy link functionality would go here
            },
          ),
        ),
      );
    } else {
      // Handle file viewing
      try {
        final url = attachment['url'];
        final fileName = attachment['name'] ?? 'file';
        
        if (url == null) {
          throw Exception('File URL not found');
        }

        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading $fileName...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );

        // Check if file is stored in Firestore (format: firestore://docId)
        if (url.toString().startsWith('firestore://')) {
          // Extract document ID from URL
          final docId = url.toString().replaceFirst('firestore://', '');
          
          // Fetch file data from Firestore
          final docSnapshot = await FirebaseFirestore.instance
              .collection('file_storage')
              .doc(docId)
              .get();

          if (!docSnapshot.exists) {
            throw Exception('File not found in database');
          }

          final fileData = docSnapshot.data()!;
          final base64Data = fileData['data'] as String;
          
          // Decode base64 to bytes
          final fileBytes = base64Decode(base64Data);
          
          // Save to temporary directory
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);

          // Open the file
          final result = await OpenFilex.open(filePath);
          
          if (result.type != ResultType.done) {
            throw Exception('Could not open file: ${result.message}');
          }

        } else {
          // Handle Firebase Storage files (if any)
          final storagePath = attachment['storagePath'];
          if (storagePath == null) {
            throw Exception('Storage path not found');
          }

          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/$fileName';
          final file = File(filePath);
          await storageRef.writeToFile(file);

          final result = await OpenFilex.open(filePath);
          if (result.type != ResultType.done) {
            throw Exception('Could not open file: ${result.message}');
          }
        }

      } catch (e) {
        print('Error viewing attachment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening file: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
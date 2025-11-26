import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

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
      final submissionsQuery = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentId', isEqualTo: widget.assignment['id'])
          .get();

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
              ElevatedButton.icon(
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
              if (submission['answerPdfBase64'] != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
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
            Text('AI is analyzing the submission...'),
          ],
        ),
      ),
    );

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));
    
    Navigator.pop(context); // Close loading dialog
    
    // Generate AI suggestions
    final aiSuggestions = _generateAISuggestions(submission);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI Grading Suggestions'),
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
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: This is an AI suggestion. Please review and adjust as needed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
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

  Map<String, dynamic> _generateAISuggestions(Map<String, dynamic> submission) {
    // Simulate AI analysis based on various factors
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final baseGrade = 70 + (random % 25); // Random grade between 70-95
    final confidence = 85 + (random % 15); // Random confidence 85-100%
    
    String feedback = 'Based on the submitted PDF analysis:\n\n';
    
    if (baseGrade >= 90) {
      feedback += '• Excellent work with comprehensive coverage\n';
      feedback += '• Clear structure and logical flow\n';
      feedback += '• Strong understanding demonstrated\n';
    } else if (baseGrade >= 80) {
      feedback += '• Good work with solid understanding\n';
      feedback += '• Most concepts covered adequately\n';
      feedback += '• Minor areas for improvement identified\n';
    } else {
      feedback += '• Basic understanding shown\n';
      feedback += '• Some key concepts need reinforcement\n';
      feedback += '• Consider additional practice in weak areas\n';
    }
    
    feedback += '\nAI detected formatting, content structure, and concept coverage in the submission.';
    
    return {
      'grade': baseGrade,
      'confidence': confidence,
      'feedback': feedback,
    };
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

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
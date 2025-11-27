import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pdf_helper.dart';
import '../../../core/utils/file_upload_helper.dart';
import '../../../data/models/assignment_model.dart';

class StudentAssignmentView extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final String studentId;
  final String studentName;

  const StudentAssignmentView({
    super.key,
    required this.assignment,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentAssignmentView> createState() => _StudentAssignmentViewState();
}

class _StudentAssignmentViewState extends State<StudentAssignmentView> {
  String? _selectedAnswerPdfBase64;
  String? _selectedPdfFileName;
  bool _isUploading = false;
  Map<String, dynamic>? _submission;

  @override
  void initState() {
    super.initState();
    _loadSubmission();
  }

  Future<void> _loadSubmission() async {
    try {
      final submissionQuery = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentId', isEqualTo: widget.assignment['id'])
          .where('studentId', isEqualTo: widget.studentId)
          .get();

      if (submissionQuery.docs.isNotEmpty) {
        setState(() {
          _submission = submissionQuery.docs.first.data();
        });
      }
    } catch (e) {
      print('Error loading submission: $e');
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
          widget.assignment['title'] ?? 'Assignment',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssignmentInfo(),
            const SizedBox(height: 20),
            // Show new attachments format if available
            if (widget.assignment['attachments'] != null && (widget.assignment['attachments'] as List).isNotEmpty)
              _buildAttachmentsSection()
            // Fallback to legacy PDF format for backward compatibility
            else if (widget.assignment['assignmentPdfBase64'] != null)
              _buildAssignmentPdfSection(),
            const SizedBox(height: 20),
            _buildSubmissionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.assignment,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assignment['title'] ?? 'Assignment',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.assignment['subject'] ?? 'Subject',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.assignment['description'] ?? 'No description',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Due: ${_formatDate(widget.assignment['dueDate'])}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildSubmissionSection() {
    if (_submission != null && _submission!['status'] == 'graded') {
      return _buildGradedSubmission();
    } else if (_submission != null) {
      return _buildSubmittedAssignment();
    } else {
      return _buildSubmissionForm();
    }
  }

  Widget _buildSubmissionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            'Submit Your Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectAnswerPdf,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedAnswerPdfBase64 == null ? 'Upload Answer PDF' : _selectedPdfFileName ?? 'PDF selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedAnswerPdfBase64 == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  if (_selectedAnswerPdfBase64 != null) ...[
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() {
                        _selectedAnswerPdfBase64 = null;
                        _selectedPdfFileName = null;
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading || _selectedAnswerPdfBase64 == null ? null : _submitAssignment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Submit Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedAssignment() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 12),
              const Text(
                'Assignment Submitted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Submitted on: ${_formatDateTime(_submission!['submittedAt'])}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Status: Waiting for grading',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradedSubmission() {
    final grade = _submission!['grade'];
    final feedback = _submission!['feedback'];
    
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Icon(Icons.grade, color: Colors.blue, size: 30),
              const SizedBox(width: 12),
              const Text(
                'Assignment Graded',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'Grade: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${grade?.toStringAsFixed(1) ?? 'N/A'}/100',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (feedback != null && feedback.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Teacher Feedback:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feedback,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Graded on: ${_formatDateTime(_submission!['gradedAt'])}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectAnswerPdf() async {
    final result = await PdfHelper.pickPdf(context);
    if (result != null) {
      setState(() {
        _selectedAnswerPdfBase64 = result['base64'];
        _selectedPdfFileName = result['name'];
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedAnswerPdfBase64 == null) return;

    setState(() => _isUploading = true);

    try {
      // Save submission
      final submissionRef = FirebaseFirestore.instance.collection('submissions').doc();
      await submissionRef.set({
        'id': submissionRef.id,
        'assignmentId': widget.assignment['id'],
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'submittedAt': DateTime.now().toIso8601String(),
        'answerPdfBase64': _selectedAnswerPdfBase64,
        'answerPdfFileName': _selectedPdfFileName,
        'status': 'submitted',
      });

      // Send notification to teacher
      await _sendSubmissionNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubmission(); // Reload to show submitted state
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assignment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _sendSubmissionNotification() async {
    // Get teacher info
    final teacherQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'Teacher')
        .get();

    for (var teacherDoc in teacherQuery.docs) {
      final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
      await notifRef.set({
        'id': notifRef.id,
        'userId': teacherDoc.id,
        'title': 'Assignment Submitted',
        'message': '${widget.studentName} submitted ${widget.assignment['title']}',
        'type': 'assignment_submitted',
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
        'data': {
          'assignmentId': widget.assignment['id'],
          'studentId': widget.studentId,
          'studentName': widget.studentName,
        },
      });
    }
  }



  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildAssignmentPdfSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            'Assignment PDF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.assignment['assignmentPdfName'] ?? 'Assignment PDF',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Tap to download assignment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // New method to display multi-file attachments
  Widget _buildAttachmentsSection() {
    final attachments = (widget.assignment['attachments'] as List)
        .map((a) => AttachmentModel.fromMap(a as Map<String, dynamic>))
        .toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
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
              const Text(
                'Assignment Files',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${attachments.length} file${attachments.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...attachments.map((attachment) => GestureDetector(
            onTap: () => _openAttachment(attachment),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FileUploadHelper.getFileColor(attachment.extension).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FileUploadHelper.getFileColor(attachment.extension).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FileUploadHelper.getFileIcon(attachment.extension),
                    color: FileUploadHelper.getFileColor(attachment.extension),
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${FileUploadHelper.formatFileSize(attachment.size)} • Tap to open',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: FileUploadHelper.getFileColor(attachment.extension),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _openAttachment(AttachmentModel attachment) async {
    try {
      final uri = Uri.parse(attachment.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open this file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAssignmentPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
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
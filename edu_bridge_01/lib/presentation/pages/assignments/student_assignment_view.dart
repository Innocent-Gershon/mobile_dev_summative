import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
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
  List<AttachmentModel> _submissionAttachments = [];
  Map<String, double> _uploadProgress = {};
  bool _isUploading = false;
  Map<String, dynamic>? _submission;

  @override
  void initState() {
    super.initState();
    print('📚 StudentAssignmentView initState');
    print('Assignment data: ${widget.assignment}');
    print('Attachments: ${widget.assignment['attachments']}');
    print('Attachments type: ${widget.assignment['attachments'].runtimeType}');
    print('Has PDF: ${widget.assignment['assignmentPdfBase64'] != null}');
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
                child: Icon(
                  _getContentIcon(widget.assignment['contentType'] ?? 'Assignment'),
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
              // Content Type Badge
              if (widget.assignment['contentType'] != null && widget.assignment['contentType'] != 'Assignment')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.assignment['contentType'] ?? '',
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
          
          // Multi-file submission section
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Submissions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickSubmissionFile,
                    icon: const Icon(Icons.add),
                    label: const Text('Add File'),
                  ),
                ],
              ),
              if (_submissionAttachments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add files, photos, or links for your submission',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._submissionAttachments.map((attachment) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FileUploadHelper.getFileIcon(attachment.extension),
                        color: FileUploadHelper.getFileColor(attachment.extension),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!attachment.isLink)
                              Text(
                                FileUploadHelper.formatFileSize(attachment.size),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (_uploadProgress.containsKey(attachment.id))
                              LinearProgressIndicator(
                                value: _uploadProgress[attachment.id],
                                backgroundColor: Colors.grey.shade200,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSubmissionFile(attachment),
                      ),
                    ],
                  ),
                )),
            ],
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading || _submissionAttachments.isEmpty ? null : _submitAssignment,
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

  Future<void> _pickSubmissionFile() async {
    // Show source selection dialog
    final source = await FileUploadHelper.showFileSourceDialog(context);
    if (source == null || !mounted) return;

    Map<String, dynamic>? result;

    switch (source) {
      case 'file':
        result = await FileUploadHelper.pickFile(context);
        break;
      case 'camera':
        result = await FileUploadHelper.pickFromCamera(context);
        break;
      case 'gallery':
        result = await FileUploadHelper.pickFromGallery(context);
        break;
      case 'link':
        result = await FileUploadHelper.addLink(context);
        break;
    }

    if (result != null && mounted) {
      if (result['isLink'] == true) {
        final attachmentId = DateTime.now().millisecondsSinceEpoch.toString();
        final attachment = AttachmentModel(
          id: attachmentId,
          name: result['name'],
          url: result['url'],
          storagePath: null,
          extension: 'link',
          size: 0,
          uploadedAt: DateTime.now(),
          isLink: true,
        );

        setState(() {
          _submissionAttachments.add(attachment);
        });
        return;
      }

      setState(() => _isUploading = true);
      
      try {
        final attachmentId = DateTime.now().millisecondsSinceEpoch.toString();
        final folderPath = 'submissions/${widget.studentId}/$attachmentId';
        
        final uploadResult = await FileUploadHelper.uploadFile(
          fileBytes: result['bytes'],
          fileName: result['name'],
          folderPath: folderPath,
          context: context,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _uploadProgress[attachmentId] = progress;
              });
            }
          },
        );
        
        if (uploadResult != null) {
          final attachment = AttachmentModel(
            id: attachmentId,
            name: result['name'],
            url: uploadResult['url']!,
            storagePath: uploadResult['path']!,
            extension: result['extension'] ?? '',
            size: result['size'],
            uploadedAt: DateTime.now(),
            isLink: false,
          );
          
          if (mounted) {
            setState(() {
              _submissionAttachments.add(attachment);
              _uploadProgress.remove(attachmentId);
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
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
  }

  Future<void> _removeSubmissionFile(AttachmentModel attachment) async {
    try {
      if (!attachment.isLink && attachment.storagePath != null) {
        await FileUploadHelper.deleteFile(attachment.storagePath!);
      }
      
      if (mounted) {
        setState(() {
          _submissionAttachments.remove(attachment);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAssignment() async {
    if (_submissionAttachments.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final submissionRef = FirebaseFirestore.instance.collection('submissions').doc();
      await submissionRef.set({
        'id': submissionRef.id,
        'assignmentId': widget.assignment['id'],
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'submittedAt': DateTime.now().toIso8601String(),
        'attachments': _submissionAttachments.map((a) => a.toMap()).toList(),
        'status': 'submitted',
      });

      await _sendSubmissionNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSubmission();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting: $e'),
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



  String _formatDate(dynamic dateValue) {
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'Invalid date';
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
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
      // Handle Firestore-stored files (base64)
      if (attachment.url.startsWith('firestore://')) {
        await _openFirestoreFile(attachment);
        return;
      }
      
      // Handle regular URLs and links
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
  
  Future<void> _openFirestoreFile(AttachmentModel attachment) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
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
                Text('Downloading file...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }
      
      // Extract file ID from firestore:// URL
      final fileId = attachment.url.replaceFirst('firestore://', '');
      
      // Download file from Firestore
      final fileBytes = await FileUploadHelper.downloadFromFirestore(fileId);
      
      if (fileBytes == null) {
        throw Exception('Failed to download file');
      }
      
      // Save to app's internal storage directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/${attachment.name}';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // Open the file using OpenFilex (handles FileProvider automatically)
      final result = await OpenFilex.open(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File opened successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (result.type == ResultType.noAppToOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No app available to open this file type'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (result.type == ResultType.fileNotFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
  
  IconData _getContentIcon(String contentType) {
    switch (contentType) {
      case 'Assignment':
        return Icons.assignment;
      case 'Book':
        return Icons.menu_book;
      case 'Presentation':
        return Icons.slideshow;
      case 'Activity':
        return Icons.psychology;
      case 'Project':
        return Icons.work;
      case 'Notes':
        return Icons.note;
      case 'Tutorial':
        return Icons.play_lesson;
      case 'Exercise':
        return Icons.fitness_center;
      default:
        return Icons.description;
    }
  }
}
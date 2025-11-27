import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/file_upload_helper.dart';
import '../../../data/models/assignment_model.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _allStudents = [];
  List<String> _selectedStudents = [];
  bool _isLoadingStudents = false;

  bool _isUploading = false;
  List<AttachmentModel> _attachments = [];
  Map<String, double> _uploadProgress = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    try {
      final QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Student')
          .get();
      
      _allStudents = studentsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown Student',
          'email': data['email'] ?? 'No email',
        };
      }).toList();
      
      // Sort students by name
      _allStudents.sort((a, b) => a['name'].compareTo(b['name']));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Assignment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormCard(),
              const SizedBox(height: 20),
              _buildStudentSelectionCard(),
              const SizedBox(height: 30),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
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
            'Assignment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Assignment Title',
              prefixIcon: const Icon(Icons.assignment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject',
              prefixIcon: const Icon(Icons.book),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => value?.isEmpty == true ? 'Subject is required' : null,
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
          ),
          
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                        ? 'Select Due Date'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // File Attachments Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _attachments.isEmpty ? Colors.red.shade300 : Colors.green.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _attachments.isEmpty ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _attachments.isEmpty ? Icons.attach_file : Icons.check_circle,
                      color: _attachments.isEmpty ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _attachments.isEmpty ? 'Upload Assignment Files *' : '${_attachments.length} file${_attachments.length > 1 ? 's' : ''} attached',
                        style: TextStyle(
                          fontSize: 16,
                          color: _attachments.isEmpty ? Colors.red : Colors.black,
                          fontWeight: _attachments.isEmpty ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!_isUploading)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6366F1)),
                        onPressed: _pickFile,
                        tooltip: 'Add file',
                      ),
                  ],
                ),
                if (_attachments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 44),
                    child: Text(
                      'PDF, Word, PowerPoint, Images, or Text files (Max 10MB)',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      final attachment = _attachments[index];
                      final isUploading = _uploadProgress.containsKey(attachment.id);
                      final progress = _uploadProgress[attachment.id] ?? 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: FileUploadHelper.getFileColor(attachment.extension).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FileUploadHelper.getFileIcon(attachment.extension),
                                  color: FileUploadHelper.getFileColor(attachment.extension),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attachment.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          FileUploadHelper.formatFileSize(attachment.size),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        if (isUploading) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '${(progress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (isUploading) ...[
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!isUploading)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _removeAttachment(index),
                                  tooltip: 'Remove',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildStudentSelectionCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assign to Students',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${_selectedStudents.length} selected',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3366FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoadingStudents)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: _allStudents.length,
                itemBuilder: (context, index) {
                  final student = _allStudents[index];
                  final isSelected = _selectedStudents.contains(student['uid']);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedStudents.add(student['uid']);
                        } else {
                          _selectedStudents.remove(student['uid']);
                        }
                      });
                    },
                    title: Text(
                      student['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(student['email']),
                    activeColor: const Color(0xFF3366FF),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _createAssignment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3366FF),
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
                    'Creating...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Create Assignment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }





  Future<void> _pickFile() async {
    if (_isUploading) return;
    
    try {
      final pickedFile = await FileUploadHelper.pickFile(context);
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      // Create temp ID for progress tracking
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _uploadProgress[tempId] = 0.0;
      });

      try {
        // Upload to Firebase Storage
        final uploadResult = await FileUploadHelper.uploadFile(
          fileBytes: pickedFile['bytes'] as Uint8List,
          fileName: pickedFile['name'] as String,
          folderPath: 'assignments',
          context: context,
          onProgress: (progress) {
            setState(() {
              _uploadProgress[tempId] = progress;
            });
          },
        );

        if (uploadResult != null) {
          // Create attachment model
          final attachment = AttachmentModel(
            id: tempId,
            name: uploadResult['name']!,
            url: uploadResult['url']!,
            storagePath: uploadResult['storagePath']!,
            extension: uploadResult['extension']!,
            size: pickedFile['size'] as int,
            uploadedAt: DateTime.now(),
          );

          setState(() {
            _uploadProgress.remove(tempId);
            _attachments.add(attachment);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${attachment.name} uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _uploadProgress.remove(tempId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _removeAttachment(int index) async {
    final attachment = _attachments[index];
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove File'),
        content: Text('Remove ${attachment.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _attachments.removeAt(index));
      
      // Delete from Firebase Storage
      try {
        await FileUploadHelper.deleteFile(attachment.storagePath);
      } catch (e) {
        // Silently fail - file may not exist yet
      }
    }
  }

  Future<void> _createAssignment() async {
    if (_formKey.currentState!.validate() && 
        _selectedDate != null && 
        _selectedStudents.isNotEmpty && 
        _attachments.isNotEmpty) {
      setState(() => _isUploading = true);
      
      try {
        final assignedStudentNames = _selectedStudents.map((studentId) {
          final student = _allStudents.firstWhere((s) => s['uid'] == studentId);
          return student['name'] as String;
        }).toList();
        
        final assignmentRef = await FirebaseFirestore.instance.collection('assignments').add({
          'title': _titleController.text,
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'dueDate': _selectedDate!.toIso8601String(),
          'assignedStudents': _selectedStudents,
          'assignedStudentNames': assignedStudentNames,
          'createdAt': DateTime.now().toIso8601String(),
          'attachments': _attachments.map((a) => a.toMap()).toList(),
          // Legacy fields for backward compatibility
          'assignmentPdfBase64': null,
          'assignmentPdfName': _attachments.isNotEmpty ? _attachments.first.name : null,
        });
        
        await _sendAssignmentNotifications(assignmentRef.id, assignedStudentNames);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating assignment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    } else {
      String errorMessage = 'Please complete all required fields:\n';
      if (!_formKey.currentState!.validate()) errorMessage += '• Fill in all form fields\n';
      if (_selectedDate == null) errorMessage += '• Select a due date\n';
      if (_selectedStudents.isEmpty) errorMessage += '• Select students\n';
      if (_attachments.isEmpty) errorMessage += '• Upload at least one file\n';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage.trim()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _sendAssignmentNotifications(String assignmentId, List<String> studentNames) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (String studentId in _selectedStudents) {
      // Notification for student
      final studentNotifRef = FirebaseFirestore.instance.collection('notifications').doc();
      batch.set(studentNotifRef, {
        'id': studentNotifRef.id,
        'userId': studentId,
        'title': 'New Assignment',
        'message': 'You have a new assignment: ${_titleController.text}',
        'type': 'assignment_created',
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
        'data': {'assignmentId': assignmentId},
      });
      
      // Find parent and send notification
      final parentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Parent')
          .where('childName', isEqualTo: _allStudents.firstWhere((s) => s['uid'] == studentId)['name'])
          .get();
      
      for (var parentDoc in parentQuery.docs) {
        final parentNotifRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(parentNotifRef, {
          'id': parentNotifRef.id,
          'userId': parentDoc.id,
          'title': 'New Assignment for ${_allStudents.firstWhere((s) => s['uid'] == studentId)['name']}',
          'message': 'Assignment: ${_titleController.text}',
          'type': 'assignment_created',
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
          'data': {'assignmentId': assignmentId},
        });
      }
    }
    
    await batch.commit();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
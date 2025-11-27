import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/pdf_helper.dart';

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
  String? _selectedAssignmentPdfBase64;
  String? _selectedAssignmentPdfName;

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
          
          GestureDetector(
            onTap: _selectAssignmentPdf,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedAssignmentPdfBase64 == null ? Colors.red.shade300 : Colors.green.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedAssignmentPdfBase64 == null ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedAssignmentPdfBase64 == null ? Icons.upload_file : Icons.picture_as_pdf,
                    color: _selectedAssignmentPdfBase64 == null ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAssignmentPdfBase64 == null ? 'Upload Assignment PDF *' : _selectedAssignmentPdfName ?? 'PDF selected',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedAssignmentPdfBase64 == null ? Colors.red : Colors.black,
                            fontWeight: _selectedAssignmentPdfBase64 == null ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                        if (_selectedAssignmentPdfBase64 == null)
                          const Text(
                            'Required: Upload the assignment PDF file',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_selectedAssignmentPdfBase64 != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() {
                        _selectedAssignmentPdfBase64 = null;
                        _selectedAssignmentPdfName = null;
                      }),
                    ),
                ],
              ),
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





  Future<void> _selectAssignmentPdf() async {
    final result = await PdfHelper.pickPdf(context);
    if (result != null) {
      setState(() {
        _selectedAssignmentPdfBase64 = result['base64'];
        _selectedAssignmentPdfName = result['name'];
      });
    }
  }

  Future<void> _createAssignment() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedStudents.isNotEmpty && _selectedAssignmentPdfBase64 != null) {
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
          'assignmentPdfBase64': _selectedAssignmentPdfBase64,
          'assignmentPdfName': _selectedAssignmentPdfName,
        });
        
        // Send notifications to students and parents
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
      if (_selectedAssignmentPdfBase64 == null) errorMessage += '• Upload assignment PDF\n';
      
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
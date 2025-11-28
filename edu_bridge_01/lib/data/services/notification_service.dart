import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendAssignmentNotificationToParent({
    required String studentId,
    required String assignmentTitle,
    required String type,
    String? grade,
  }) async {
    try {
      final parentQuery = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Parent')
          .where('childName', isEqualTo: await _getStudentName(studentId))
          .limit(1)
          .get();

      if (parentQuery.docs.isEmpty) return;

      final parentId = parentQuery.docs.first.id;
      final studentName = await _getStudentName(studentId);

      String title;
      String message;

      switch (type) {
        case 'assignment_created':
          title = 'New Assignment';
          message = 'Your child $studentName has been assigned: $assignmentTitle';
          break;
        case 'assignment_submitted':
          title = 'Assignment Submitted';
          message = '$studentName has submitted: $assignmentTitle';
          break;
        case 'assignment_graded':
          title = 'Assignment Graded';
          message = '$studentName received ${grade ?? 'a grade'} for: $assignmentTitle';
          break;
        default:
          return;
      }

      await _firestore.collection('notifications').add({
        'userId': parentId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'studentId': studentId,
        'assignmentTitle': assignmentTitle,
        'grade': grade,
      });
    } catch (e) {
      // Silently handle errors
    }
  }

  static Future<String> _getStudentName(String studentId) async {
    try {
      final studentDoc = await _firestore.collection('users').doc(studentId).get();
      return studentDoc.data()?['name'] ?? 'Student';
    } catch (e) {
      return 'Student';
    }
  }
}
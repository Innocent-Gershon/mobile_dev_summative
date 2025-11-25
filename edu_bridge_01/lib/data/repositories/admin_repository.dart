import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, int>> getUserStats() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      int totalUsers = snapshot.docs.length;
      int students = 0;
      int teachers = 0;
      int parents = 0;

      for (var doc in snapshot.docs) {
        final userType = doc.data()['userType'] as String? ?? 'Student';
        switch (userType) {
          case 'Student':
            students++;
            break;
          case 'Teacher':
            teachers++;
            break;
          case 'Parent':
            parents++;
            break;
        }
      }

      return {
        'totalUsers': totalUsers,
        'students': students,
        'teachers': teachers,
        'parents': parents,
      };
    });
  }

  Stream<int> getCoursesCount() {
    return _firestore.collection('classes').snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getAssignmentsCount() {
    return _firestore.collection('assignments').snapshots().map((snapshot) => snapshot.docs.length);
  }
}
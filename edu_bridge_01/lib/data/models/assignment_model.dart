class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final List<String> assignedStudents;
  final String teacherId;
  final DateTime createdAt;
  final String? questionPdfUrl;
  final String? questionPdfName;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.assignedStudents,
    required this.teacherId,
    required this.createdAt,
    this.questionPdfUrl,
    this.questionPdfName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': dueDate,
      'assignedStudents': assignedStudents,
      'teacherId': teacherId,
      'createdAt': createdAt,
      'questionPdfUrl': questionPdfUrl,
      'questionPdfName': questionPdfName,
    };
  }
}

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final String? answerPdfUrl;
  final String? answerPdfName;
  final String status;
  final double? grade;
  final String? feedback;
  final DateTime? gradedAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    this.answerPdfUrl,
    this.answerPdfName,
    required this.status,
    this.grade,
    this.feedback,
    this.gradedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'submittedAt': submittedAt,
      'answerPdfUrl': answerPdfUrl,
      'answerPdfName': answerPdfName,
      'status': status,
      'grade': grade,
      'feedback': feedback,
      'gradedAt': gradedAt,
    };
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt,
      'isRead': isRead,
      'data': data,
    };
  }
}
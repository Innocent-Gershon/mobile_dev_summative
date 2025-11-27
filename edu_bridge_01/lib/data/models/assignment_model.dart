import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<AttachmentModel>? attachments; // Support multiple attachments

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
    this.attachments,
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
      'attachments': attachments?.map((a) => a.toMap()).toList(),
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      assignedStudents: List<String>.from(map['assignedStudents'] ?? []),
      teacherId: map['teacherId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      questionPdfUrl: map['questionPdfUrl'],
      questionPdfName: map['questionPdfName'],
      attachments: map['attachments'] != null
          ? (map['attachments'] as List)
              .map((a) => AttachmentModel.fromMap(a))
              .toList()
          : null,
    );
  }
}

class AttachmentModel {
  final String id;
  final String name;
  final String url;
  final String? storagePath; // Optional for links
  final String extension;
  final int size;
  final DateTime uploadedAt;
  final bool isLink; // Flag to identify if it's a link

  AttachmentModel({
    required this.id,
    required this.name,
    required this.url,
    this.storagePath,
    required this.extension,
    required this.size,
    required this.uploadedAt,
    this.isLink = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'storagePath': storagePath,
      'extension': extension,
      'size': size,
      'uploadedAt': uploadedAt,
      'isLink': isLink,
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      storagePath: map['storagePath'],
      extension: map['extension'] ?? '',
      size: map['size'] ?? 0,
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      isLink: map['isLink'] ?? false,
    );
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
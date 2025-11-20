class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final List<String> assignedStudents;
  final String teacherId;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.assignedStudents,
    required this.teacherId,
    required this.createdAt,
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
    };
  }
}
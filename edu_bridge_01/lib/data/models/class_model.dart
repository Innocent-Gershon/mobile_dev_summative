class ClassModel {
  final String id;
  final String name;
  final String teacher;
  final String subject;
  final String icon;
  final double progress;
  final String nextAssignment;
  final String dueDate;
  final String color;
  final List<String> assignedStudents;
  final String description;

  ClassModel({
    required this.id,
    required this.name,
    required this.teacher,
    required this.subject,
    required this.icon,
    required this.progress,
    required this.nextAssignment,
    required this.dueDate,
    required this.color,
    this.assignedStudents = const [],
    this.description = '',
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      teacher: json['teacher'] ?? '',
      subject: json['subject'] ?? '',
      icon: json['icon'] ?? '📚',
      progress: (json['progress'] ?? 0.0).toDouble(),
      nextAssignment: json['nextAssignment'] ?? '',
      dueDate: json['dueDate'] ?? '',
      color: json['color'] ?? 'blue',
      assignedStudents: List<String>.from(json['assignedStudents'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'subject': subject,
      'icon': icon,
      'progress': progress,
      'nextAssignment': nextAssignment,
      'dueDate': dueDate,
      'color': color,
      'assignedStudents': assignedStudents,
      'description': description,
    };
  }
}
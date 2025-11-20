class ClassModel {
  final String id;
  final String name;
  final String teacher;
  final String subject;
  final double progress;
  final String nextAssignment;
  final String dueDate;
  final String icon;
  final String color;

  ClassModel({
    required this.id,
    required this.name,
    required this.teacher,
    required this.subject,
    required this.progress,
    required this.nextAssignment,
    required this.dueDate,
    required this.icon,
    required this.color,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      teacher: json['teacher'] ?? '',
      subject: json['subject'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      nextAssignment: json['nextAssignment'] ?? '',
      dueDate: json['dueDate'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'subject': subject,
      'progress': progress,
      'nextAssignment': nextAssignment,
      'dueDate': dueDate,
      'icon': icon,
      'color': color,
    };
  }
}
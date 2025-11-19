import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

enum UserType { teacher, student, parent, guest }

UserType stringToUserType(String roleString) {
  switch (roleString.toLowerCase()) {
    case 'student':
      return UserType.student;
    case 'teacher':
      return UserType.teacher;
    case 'parent':
      return UserType.parent;
    case 'admin':
      return UserType.teacher;
    default:
      return UserType.guest;
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final Color priorityColor;
  final String dueDate;
  final List<String> tags;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
    required this.tags,
    this.isCompleted = false,
  });
}

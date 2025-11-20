import 'package:equatable/equatable.dart';

abstract class ClassesEvent extends Equatable {
  const ClassesEvent();

  @override
  List<Object> get props => [];
}

class LoadClasses extends ClassesEvent {}

class RefreshClasses extends ClassesEvent {}

class AddClass extends ClassesEvent {
  final String name;
  final String teacher;
  final String icon;
  final String color;

  const AddClass({
    required this.name,
    required this.teacher,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [name, teacher, icon, color];
}
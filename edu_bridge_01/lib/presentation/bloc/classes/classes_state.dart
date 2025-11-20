import '../../../data/models/class_model.dart';

abstract class ClassesState {}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;

  ClassesLoaded({required this.classes});
}

class ClassesError extends ClassesState {
  final String message;

  ClassesError({required this.message});
}
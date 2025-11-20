import 'package:equatable/equatable.dart';
import '../../../data/models/class_model.dart';

abstract class ClassesState extends Equatable {
  const ClassesState();

  @override
  List<Object> get props => [];
}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;

  const ClassesLoaded(this.classes);

  @override
  List<Object> get props => [classes];
}

class ClassesError extends ClassesState {
  final String message;

  const ClassesError(this.message);

  @override
  List<Object> get props => [message];
}
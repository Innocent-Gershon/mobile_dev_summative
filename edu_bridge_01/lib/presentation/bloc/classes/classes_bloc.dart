import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/class_model.dart';
import 'classes_event.dart';
import 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  ClassesBloc() : super(ClassesInitial()) {
    on<LoadClasses>(_onLoadClasses);
    on<RefreshClasses>(_onRefreshClasses);
    on<AddClass>(_onAddClass);
  }

  void _onLoadClasses(LoadClasses event, Emitter<ClassesState> emit) async {
    emit(ClassesLoading());
    
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      final classes = [
        ClassModel(
          id: '1',
          name: 'Mathematics',
          teacher: 'Mr. Johnson',
          subject: 'Mathematics',
          icon: '📐',
          progress: 0.75,
          nextAssignment: 'Algebra Quiz',
          dueDate: 'Tomorrow',
          color: 'blue',
        ),
        ClassModel(
          id: '2',
          name: 'Science',
          teacher: 'Ms. Davis',
          subject: 'Science',
          icon: '🔬',
          progress: 0.60,
          nextAssignment: 'Lab Report',
          dueDate: 'Friday',
          color: 'green',
        ),
        ClassModel(
          id: '3',
          name: 'History',
          teacher: 'Mr. Wilson',
          subject: 'History',
          icon: '📚',
          progress: 0.85,
          nextAssignment: 'Essay on WWII',
          dueDate: 'Next Week',
          color: 'brown',
        ),
      ];
      
      emit(ClassesLoaded(classes));
    } catch (e) {
      emit(ClassesError('Failed to load classes: ${e.toString()}'));
    }
  }

  void _onRefreshClasses(RefreshClasses event, Emitter<ClassesState> emit) async {
    // Reload classes
    add(LoadClasses());
  }

  void _onAddClass(AddClass event, Emitter<ClassesState> emit) async {
    if (state is ClassesLoaded) {
      final currentClasses = (state as ClassesLoaded).classes;
      final newClass = ClassModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        teacher: event.teacher,
        subject: event.name,
        icon: event.icon,
        progress: 0.0,
        nextAssignment: 'No assignments yet',
        dueDate: 'TBD',
        color: event.color,
      );
      
      emit(ClassesLoaded([...currentClasses, newClass]));
    }
  }
}
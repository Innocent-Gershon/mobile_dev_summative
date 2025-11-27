import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      await emit.forEach(
        FirebaseFirestore.instance
            .collection('assignments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        onData: (QuerySnapshot snapshot) {
          final classes = snapshot.docs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            final studentNames = List<String>.from(data['assignedStudentNames'] ?? []);
            print('Assignment: ${data['title']}, Students: $studentNames'); // Debug
            return ClassModel(
              id: doc.id,
              name: data['subject'] ?? 'Unknown Subject',
              teacher: 'Teacher',
              subject: data['subject'] ?? 'Unknown Subject',
              icon: _getSubjectIcon(data['subject'] ?? ''),
              progress: 0.0,
              nextAssignment: data['title'] ?? 'No title',
              dueDate: _formatDueDate(data['dueDate']),
              color: _getCyclingColor(index),
              assignedStudents: studentNames,
              description: data['description'] ?? 'No description provided',
            );
          }).toList();
          return ClassesLoaded(classes);
        },
        onError: (error, stackTrace) => ClassesError('Failed to load classes: $error'),
      );
    } catch (e) {
      emit(ClassesError('Failed to load classes: ${e.toString()}'));
    }
  }
  
  String _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return '📐';
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
        return '🔬';
      case 'history':
        return '📚';
      case 'english':
      case 'literature':
        return '📖';
      case 'art':
        return '🎨';
      case 'music':
        return '🎵';
      default:
        return '📝';
    }
  }
  
  String _getCyclingColor(int index) {
    final colors = ['blue', 'green', 'purple', 'orange', 'teal'];
    return colors[index % colors.length];
  }
  
  String _formatDueDate(dynamic dueDate) {
    if (dueDate == null) return 'No due date';
    try {
      final date = DateTime.parse(dueDate.toString());
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Tomorrow';
      if (difference > 1 && difference <= 7) return 'In $difference days';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
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
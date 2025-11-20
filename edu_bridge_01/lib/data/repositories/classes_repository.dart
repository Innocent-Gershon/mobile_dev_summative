import '../models/class_model.dart';

class ClassesRepository {
  // Mock data - replace with Firebase implementation
  Future<List<ClassModel>> getClasses() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    return [
      ClassModel(
        id: '1',
        name: 'Mathematics',
        teacher: 'Mr. Julio',
        subject: 'Mathematics',
        progress: 0.92,
        nextAssignment: 'Algebra Assignment - Due Fri',
        dueDate: 'Fri',
        icon: '√x',
        color: 'green',
      ),
      ClassModel(
        id: '2',
        name: 'Science',
        teacher: 'Mr. Abraham',
        subject: 'Science',
        progress: 0.87,
        nextAssignment: 'Lab Report - Due Wed',
        dueDate: 'Wed',
        icon: '🧪',
        color: 'blue',
      ),
      ClassModel(
        id: '3',
        name: 'Literature',
        teacher: 'Mrs. Kasande',
        subject: 'Literature',
        progress: 0.46,
        nextAssignment: 'Essay Assignment - Due Mon',
        dueDate: 'Mon',
        icon: '📚',
        color: 'brown',
      ),
    ];
  }

  Future<ClassModel?> getClassById(String id) async {
    final classes = await getClasses();
    try {
      return classes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
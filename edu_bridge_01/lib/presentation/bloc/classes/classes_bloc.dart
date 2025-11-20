import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/class_model.dart';
import '../../../data/repositories/classes_repository.dart';
import 'classes_event.dart';
import 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final ClassesRepository _repository;

  ClassesBloc({ClassesRepository? repository}) 
      : _repository = repository ?? ClassesRepository(),
        super(ClassesInitial()) {
    on<LoadClasses>(_onLoadClasses);
    on<RefreshClasses>(_onRefreshClasses);
  }

  void _onLoadClasses(LoadClasses event, Emitter<ClassesState> emit) async {
    emit(ClassesLoading());
    try {
      final classes = await _repository.getClasses();
      emit(ClassesLoaded(classes: classes));
    } catch (e) {
      emit(ClassesError(message: e.toString()));
    }
  }

  void _onRefreshClasses(RefreshClasses event, Emitter<ClassesState> emit) async {
    try {
      final classes = await _repository.getClasses();
      emit(ClassesLoaded(classes: classes));
    } catch (e) {
      emit(ClassesError(message: e.toString()));
    }
  }
}
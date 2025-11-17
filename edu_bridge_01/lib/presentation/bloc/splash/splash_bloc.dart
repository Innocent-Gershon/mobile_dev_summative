import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  int _currentPage = 0;
  static const int _totalPages = 3;

  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashNextPressed>(_onSplashNextPressed);
    on<SplashSkipPressed>(_onSplashSkipPressed);
    on<SplashCompleted>(_onSplashCompleted);
  }

  void _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) {
    _currentPage = 0;
    emit(SplashPageChanged(_currentPage));
  }

  void _onSplashNextPressed(SplashNextPressed event, Emitter<SplashState> emit) {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      emit(SplashPageChanged(_currentPage));
    } else {
      emit(SplashNavigateToAuth());
    }
  }

  void _onSplashSkipPressed(SplashSkipPressed event, Emitter<SplashState> emit) {
    emit(SplashNavigateToAuth());
  }

  void _onSplashCompleted(SplashCompleted event, Emitter<SplashState> emit) {
    emit(SplashNavigateToAuth());
  }
}
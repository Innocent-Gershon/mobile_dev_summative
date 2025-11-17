import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {}

class SplashNextPressed extends SplashEvent {}

class SplashSkipPressed extends SplashEvent {}

class SplashCompleted extends SplashEvent {}
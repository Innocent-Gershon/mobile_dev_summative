import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashPageChanged extends SplashState {
  final int currentPage;

  const SplashPageChanged(this.currentPage);

  @override
  List<Object> get props => [currentPage];
}

class SplashNavigateToAuth extends SplashState {}
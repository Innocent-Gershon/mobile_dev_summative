import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LoginWithGoogleEvent extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String userType;
  final Map<String, String> additionalData;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
    required this.additionalData,
  });

  @override
  List<Object> get props => [email, password, fullName, userType, additionalData];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class CompleteGoogleSignInEvent extends AuthEvent {
  final String uid;
  final String email;
  final String name;
  final String userType;

  const CompleteGoogleSignInEvent({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
  });

  @override
  List<Object> get props => [uid, email, name, userType];
}

class CheckEmailVerificationEvent extends AuthEvent {}

class ResendVerificationEmailEvent extends AuthEvent {
  final String email;

  const ResendVerificationEmailEvent(this.email);

  @override
  List<Object> get props => [email];
}
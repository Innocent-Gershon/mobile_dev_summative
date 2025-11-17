import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String name;
  final String userType; // ✅ Added userType here

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.name,
    required this.userType, // ✅ Added to constructor
  });

  @override
  List<Object> get props => [userId, email, name, userType];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

class AuthGoogleSignInNeedsRole extends AuthState {
  final User user;
  final String email;
  final String name;

  const AuthGoogleSignInNeedsRole({
    required this.user,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [user, email, name];
}

class AuthEmailVerificationSent extends AuthState {
  final String email;

  const AuthEmailVerificationSent(this.email);

  @override
  List<Object> get props => [email];
}

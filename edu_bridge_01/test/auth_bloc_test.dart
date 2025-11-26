import 'package:flutter_test/flutter_test.dart';
import 'package:edu_bridge_01/presentation/bloc/auth/auth_state.dart';
import 'package:edu_bridge_01/presentation/bloc/auth/auth_event.dart';

void main() {
  group('AuthBloc Educational State Testing', () {
    test('AuthInitial state should be equal to itself', () {
      final state1 = AuthInitial();
      final state2 = AuthInitial();
      expect(state1, equals(state2));
    });

    test('AuthLoading state should be equal to itself', () {
      final state1 = AuthLoading();
      final state2 = AuthLoading();
      expect(state1, equals(state2));
    });

    test('AuthAuthenticated state should contain educational user data', () {
      const studentState = AuthAuthenticated(
        userId: 'student123',
        email: 'student@school.edu',
        name: 'John Student',
        userType: 'Student',
      );
      
      expect(studentState.userId, equals('student123'));
      expect(studentState.email, equals('student@school.edu'));
      expect(studentState.name, equals('John Student'));
      expect(studentState.userType, equals('Student'));
    });

    test('AuthError state should contain error message', () {
      const errorState = AuthError('Invalid credentials');
      expect(errorState.message, equals('Invalid credentials'));
    });

    test('AuthEmailVerificationSent state should contain email', () {
      const verificationState = AuthEmailVerificationSent('teacher@school.edu');
      expect(verificationState.email, equals('teacher@school.edu'));
    });

    test('Educational user types should be properly defined', () {
      const studentAuth = AuthAuthenticated(
        userId: 'id1', email: 'test@test.com', name: 'Test', userType: 'Student',
      );
      const teacherAuth = AuthAuthenticated(
        userId: 'id2', email: 'test@test.com', name: 'Test', userType: 'Teacher',
      );
      const parentAuth = AuthAuthenticated(
        userId: 'id3', email: 'test@test.com', name: 'Test', userType: 'Parent',
      );
      const adminAuth = AuthAuthenticated(
        userId: 'id4', email: 'test@test.com', name: 'Test', userType: 'Admin',
      );
      
      expect(studentAuth.userType, equals('Student'));
      expect(teacherAuth.userType, equals('Teacher'));
      expect(parentAuth.userType, equals('Parent'));
      expect(adminAuth.userType, equals('Admin'));
    });

    test('Educational events should be properly defined', () {
      const loginEvent = LoginWithEmailEvent(
        email: 'student@school.edu',
        password: 'password123',
      );
      const signupEvent = SignUpWithEmailEvent(
        email: 'teacher@school.edu',
        password: 'password123',
        fullName: 'Teacher Name',
        userType: 'Teacher',
        additionalData: {},
      );
      
      expect(loginEvent.email, equals('student@school.edu'));
      expect(loginEvent.password, equals('password123'));
      expect(signupEvent.userType, equals('Teacher'));
      expect(signupEvent.fullName, equals('Teacher Name'));
    });
  });

  group('Educational Authentication Flow Tests', () {
    test('Authentication states should support educational workflows', () {
      // Test that all required states exist for educational platform
      expect(AuthInitial(), isA<AuthState>());
      expect(AuthLoading(), isA<AuthState>());
      expect(AuthUnauthenticated(), isA<AuthState>());
      expect(const AuthError('Test error'), isA<AuthState>());
      expect(const AuthAuthenticated(
        userId: 'test', email: 'test@test.com', name: 'Test', userType: 'Student'
      ), isA<AuthState>());
    });

    test('Educational events should support multi-role authentication', () {
      // Test that all required events exist for educational platform
      expect(const LoginWithEmailEvent(email: 'test@test.com', password: 'pass'), isA<AuthEvent>());
      expect(AuthLogoutRequested(), isA<AuthEvent>());
      expect(AuthCheckRequested(), isA<AuthEvent>());
      expect(const AuthPasswordResetRequested(email: 'test@test.com'), isA<AuthEvent>());
    });
  });
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<CompleteGoogleSignInEvent>(_onCompleteGoogleSignIn);
    on<CheckEmailVerificationEvent>(_onCheckEmailVerification);
    on<ResendVerificationEmailEvent>(_onResendVerificationEmail);
  }

  void _onLoginWithEmail(LoginWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final userData = await _authRepository.getUserData(user.uid);
        
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? event.email,
          name: userData?['name'] ?? user.displayName ?? 'User',
          userType: userData?['userType'] ?? 'Student',
        ));
      } else {
        emit(const AuthError('Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '❌ No account found with this email. You need to register first!';
          emit(AuthError('SHOW_REGISTER_DIALOG:$errorMessage'));
          return;
        case 'wrong-password':
          errorMessage = '🔐 Oops! Wrong password. Double-check and try again.';
          emit(AuthError('SHOW_PASSWORD_DIALOG:$errorMessage'));
          return;
        case 'invalid-credential':
          // Check if user exists to determine if it's wrong password or no account
          try {
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(event.email);
            // If we get here, user exists, so it's wrong password
            errorMessage = '🔐 Oops! Wrong password. Double-check and try again.';
            emit(AuthError('SHOW_PASSWORD_DIALOG:$errorMessage'));
          } catch (fetchError) {
            // User doesn't exist
            errorMessage = '❌ No account found with this email. You need to register first!';
            emit(AuthError('SHOW_REGISTER_DIALOG:$errorMessage'));
          }
          return;
        case 'invalid-email':
          errorMessage = '📧 Invalid email format. Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = '⛔ Account suspended. Contact support for assistance.';
          break;
        case 'too-many-requests':
          errorMessage = '⏰ Too many attempts! Please wait a moment and try again.';
          break;
        case 'network-request-failed':
          errorMessage = '🌐 Network error. Check your internet connection.';
          break;
        default:
          errorMessage = '⚠️ Login failed: ${e.message}';
      }
      
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  void _onLoginWithGoogle(LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      
      if (userCredential == null) {
        emit(AuthUnauthenticated());
        return;
      }
      
      final user = userCredential.user;
      if (user == null) {
        emit(const AuthError('Google sign in failed'));
        return;
      }
      
      // First check if user data exists by UID
      var userData = await _authRepository.getUserData(user.uid);
      
      // If no data by UID, check by email (for existing email/password accounts)
      if (userData == null && user.email != null) {
        userData = await _authRepository.getUserDataByEmail(user.email!);
        
        // If found by email, link the accounts
        if (userData != null) {
          await _authRepository.linkGoogleAccount(user.uid, userData);
        }
      }
      
      if (userData == null) {
        emit(AuthGoogleSignInNeedsRole(
          user: user,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
        ));
      } else {
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? '',
          name: userData['name'] ?? user.displayName ?? 'User',
          userType: userData['userType'] ?? 'Student',
        ));
      }
    } catch (e) {
      String errorMessage = 'Google sign in failed';
      
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Google Sign-In not available on this device.';
      } else {
        errorMessage = 'Google sign in failed: ${e.toString()}';
      }
      
      emit(AuthError(errorMessage));
    }
  }

  void _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // TODO: Implement Firebase sign up
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      emit(const AuthAuthenticated(
        userId: 'newuser123',
        email: 'newuser@example.com',
        name: 'New User',
        userType: 'Student',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed'));
    }
  }

  void _onSignUpWithEmail(SignUpWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // For parents, validate student exists first
      if (event.userType == 'Parent' && event.additionalData?['childName'] != null) {
        final studentName = event.additionalData!['childName'] as String;
        final studentExists = await _authRepository.isStudentRegistered(studentName);
        
        if (!studentExists) {
          emit(AuthError('STUDENT_NOT_FOUND:$studentName'));
          return;
        }
      }
      
      final userCredential = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        await _authRepository.saveUserData(
          uid: user.uid,
          email: event.email,
          name: event.fullName,
          userType: event.userType,
          additionalData: event.additionalData,
        );
        
        // Skip email verification for parents and go directly to home
        if (event.userType == 'Parent') {
          emit(AuthAuthenticated(
            userId: user.uid,
            email: event.email,
            name: event.fullName,
            userType: event.userType,
          ));
        } else {
          await user.sendEmailVerification();
          emit(AuthEmailVerificationSent(event.email));
        }
      } else {
        emit(const AuthError('Sign up failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      bool showLoginDialog = false;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = '🔒 Password too weak! Use 6+ characters with letters & numbers.';
          break;
        case 'email-already-in-use':
          errorMessage = '📝 Email already registered! Looks like you already have an account.';
          showLoginDialog = true;
          break;
        case 'invalid-email':
          errorMessage = '📧 Invalid email format. Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = '⛔ Registration disabled. Contact support for assistance.';
          break;
        case 'network-request-failed':
          errorMessage = '🌐 Network error. Check your internet connection.';
          break;
        default:
          errorMessage = '⚠️ Registration failed: ${e.message}';
      }
      
      if (showLoginDialog) {
        emit(AuthError('SHOW_LOGIN_DIALOG:$errorMessage'));
      } else {
        emit(AuthError(errorMessage));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final userData = await _authRepository.getUserData(user.uid);
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? '',
          name: userData?['name'] ?? user.displayName ?? 'User',
          userType: userData?['userType'] ?? 'Student',
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  void _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(event.email));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }

  void _onCompleteGoogleSignIn(CompleteGoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.saveUserData(
        uid: event.uid,
        email: event.email,
        name: event.name,
        userType: event.userType,
      );
      
      // Send email verification if not already verified
      final user = _authRepository.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        emit(AuthEmailVerificationSent(event.email));
      } else {
        emit(AuthAuthenticated(
          userId: event.uid,
          email: event.email,
          name: event.name,
          userType: event.userType,
        ));
      }
    } catch (e) {
      emit(AuthError('Failed to save user data: ${e.toString()}'));
    }
  }

  void _onCheckEmailVerification(CheckEmailVerificationEvent event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _authRepository.currentUser;
        
        if (updatedUser != null && updatedUser.emailVerified) {
          final userData = await _authRepository.getUserData(updatedUser.uid);
          emit(AuthAuthenticated(
            userId: updatedUser.uid,
            email: updatedUser.email ?? '',
            name: userData?['name'] ?? updatedUser.displayName ?? 'User',
            userType: userData?['userType'] ?? 'Student',
          ));
        } else {
          emit(AuthError('Email not verified yet. Please check your email.'));
        }
      }
    } catch (e) {
      emit(AuthError('Failed to check verification: ${e.toString()}'));
    }
  }

  void _onResendVerificationEmail(ResendVerificationEmailEvent event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        emit(AuthEmailVerificationSent(event.email));
      }
    } catch (e) {
      emit(AuthError('Failed to resend verification email: ${e.toString()}'));
    }
  }
}
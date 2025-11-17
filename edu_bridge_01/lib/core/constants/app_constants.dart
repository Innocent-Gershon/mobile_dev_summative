import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
}

class AppStrings {
  static const String appName = 'EduBridge';
  static const String tagline = 'Bridging the gap between learners and educators';
  
  // Splash Screens
  static const String splash1Title = 'Welcome to EduBridge';
  static const String splash1Subtitle = 'Your journey to knowledge starts here';
  static const String splash2Title = 'Find Your Perfect Tutor';
  static const String splash2Subtitle = 'Connect with expert educators tailored to your learning needs';
  static const String splash3Title = 'Learn at Your Own Pace';
  static const String splash3Subtitle = 'Flexible learning that adapts to your schedule and style';
  
  // Buttons
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String continueWithGoogle = 'Continue with Google';
}

class AppConstants {
  // User Types
  static const String student = 'Student';
  static const String teacher = 'Teacher';
  static const String parent = 'Parent';
  static const String admin = 'Admin';
  
  // Form Fields
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String phoneNumber = 'Phone Number';
  static const String childName = 'Child Name';
  static const String childClass = 'Child Class';
  
  // Welcome Messages
  static const String studentWelcome = 'Welcome Back, Student!';
  static const String teacherWelcome = 'Welcome Back, Educator!';
  static const String parentWelcome = 'Welcome Back, Parent!';
  static const String adminWelcome = 'Welcome Back, Admin!';
  
  // Subtitle Messages
  static const String studentSubtitle = 'Continue your learning journey';
  static const String teacherSubtitle = 'Inspire and educate your students';
  static const String parentSubtitle = 'Monitor your child\'s progress';
  static const String adminSubtitle = 'Manage the educational platform';
  
  // Signup Messages
  static const String studentSignup = 'Join as Student';
  static const String teacherSignup = 'Join as Educator';
  static const String parentSignup = 'Join as Parent';
  static const String adminSignup = 'Join as Admin';
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
}
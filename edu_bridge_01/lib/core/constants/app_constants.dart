import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3366FF);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = Color(0xFF5B8DEF);
  static const Color accent = Color(0xFF34C759);
  static const Color accentLight = Color(0xFF4ADE80);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF10B981);
  static const Color border = Color(0xFFE0E0E0);
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double buttonHeight = 48.0;
}

class AppStrings {
  static const String appName = 'EduBridge';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String tagline = 'Connecting Education, Empowering Futures';
  static const String splash2Title = 'Interactive Learning';
  static const String splash2Subtitle = 'Engage with dynamic content and track your progress in real-time';
  static const String splash3Title = 'Connect & Collaborate';
  static const String splash3Subtitle = 'Join a community of learners and educators working together';
}

class AppConstants {
  // User types
  static const String student = 'Student';
  static const String teacher = 'Teacher';
  static const String parent = 'Parent';
  static const String admin = 'Admin';
  
  // Form labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  
  // Welcome messages
  static const String studentWelcome = 'Welcome Back, Student!';
  static const String teacherWelcome = 'Welcome Back, Teacher!';
  static const String parentWelcome = 'Welcome Back, Parent!';
  static const String adminWelcome = 'Welcome Back, Admin!';
  
  // Subtitles
  static const String studentSubtitle = 'Continue your learning journey';
  static const String teacherSubtitle = 'Manage your classes and students';
  static const String parentSubtitle = 'Track your child\'s progress';
  static const String adminSubtitle = 'Oversee the educational system';
  
  // Signup titles
  static const String studentSignup = 'Student Registration';
  static const String teacherSignup = 'Teacher Registration';
  static const String parentSignup = 'Parent Registration';
  static const String adminSignup = 'Admin Registration';
  
  // Parent-specific fields
  static const String phoneNumber = 'Phone Number';
  static const String childName = 'Child\'s Name';
  static const String childClass = 'Child\'s Class';
  
  // Additional form fields
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
}
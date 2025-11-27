import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/role_selection_dialog.dart';
import '../../../core/constants/app_constants.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedUserType = AppConstants.student;
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            String displayMessage = state.message;
            bool shouldShowDialog = false;
            

            
            // Check for special dialog triggers
            if (state.message.startsWith('SHOW_REGISTER_DIALOG:')) {
              displayMessage = state.message.substring('SHOW_REGISTER_DIALOG:'.length);
              shouldShowDialog = true;
            }
            
            bool shouldShowPasswordDialog = false;
            if (state.message.startsWith('SHOW_PASSWORD_DIALOG:')) {
              displayMessage = state.message.substring('SHOW_PASSWORD_DIALOG:'.length);
              shouldShowPasswordDialog = true;
            }
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(displayMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            
            // Show register dialog if user not found
            if (shouldShowDialog) {
              Future.delayed(const Duration(milliseconds: 800), () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(
                      children: [
                        Icon(Icons.person_add, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        const Text('Create Account?'),
                      ],
                    ),
                    content: const Text('No account exists with this email address. Create a new account to get started with EduBridge!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Maybe Later'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
                );
              });
            }
            
            // Show password reset dialog for wrong password
            if (shouldShowPasswordDialog) {
              Future.delayed(const Duration(milliseconds: 800), () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(
                      children: [
                        const Icon(Icons.lock_reset, color: Colors.orange),
                        const SizedBox(width: 10),
                        const Text('Wrong Password'),
                      ],
                    ),
                    content: const Text('The password you entered is incorrect. Would you like to reset your password or try again?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Try Again'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Reset Password'),
                      ),
                    ],
                  ),
                );
              });
            }
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          } else if (state is AuthGoogleSignInNeedsRole) {
            // Show role selection dialog for Google sign-in
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RoleSelectionDialog(
                onRoleSelected: (role) {
                  context.read<AuthBloc>().add(
                    CompleteGoogleSignInEvent(
                      uid: state.user.uid,
                      email: state.email,
                      name: state.name,
                      userType: role,
                    ),
                  );
                },
              ),
            );
          } else if (state is AuthEmailVerificationSent) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmailVerificationScreen(email: state.email),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // --- Main Content (always present) ---
              // This is where your form and other UI elements reside.
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 1),

                        // EduBridge title with icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school,
                              size: 32,
                              color: isDark ? Colors.white : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EduBridge',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color: isDark ? Colors.white : null,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Welcome back text
                        Text(
                          _getWelcomeMessage(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.white : null,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _getSubtitleMessage(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : null,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Creative user type selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDropdownOpen = !_isDropdownOpen;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 200,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.blue.shade400,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getUserTypeIcon(_selectedUserType),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedUserType,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _isDropdownOpen ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Role-specific name field
                        if (_selectedUserType == AppConstants.student)
                          TextFormField(
                            controller: _studentIdController,
                            decoration: const InputDecoration(
                              labelText: 'Student Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your student name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                        if (_selectedUserType == AppConstants.teacher)
                          TextFormField(
                            controller: _employeeIdController,
                            decoration: const InputDecoration(
                              labelText: 'Employee Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your employee name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                        if (_selectedUserType != AppConstants.student &&
                            _selectedUserType != AppConstants.teacher)
                          const SizedBox(height: 0),

                        if (_selectedUserType == AppConstants.student ||
                            _selectedUserType == AppConstants.teacher)
                          const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _selectedUserType == AppConstants.student
                                ? 'Email Address'
                                : _selectedUserType == AppConstants.teacher
                                ? 'Email Address'
                                : AppConstants.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppConstants.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppConstants.forgotPassword,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      // Check if fields are not empty
                                      if (_emailController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter your email'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                      if (_passwordController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter your password'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }

                                      final additionalData = <String, String>{};
                                      if (_selectedUserType ==
                                          AppConstants.student) {
                                        additionalData['studentId'] =
                                            _studentIdController.text.trim();
                                      } else if (_selectedUserType ==
                                          AppConstants.teacher) {
                                        additionalData['employeeId'] =
                                            _employeeIdController.text.trim();
                                      }
                                      additionalData['userType'] =
                                          _selectedUserType;

                                      context.read<AuthBloc>().add(
                                        LoginWithEmailEvent(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    AppConstants.login,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color.fromARGB(255, 42, 40, 40),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Social login buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                          LoginWithGoogleEvent(),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://developers.google.com/identity/images/g-logo.png',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                label: Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        // TODO: Apple login
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.apple,
                                  size: 20,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                label: Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        // TODO: Facebook login
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.facebook,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                label: Text(
                                  'Facebook',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color.fromARGB(255, 42, 40, 40),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppConstants.signUp,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Modal Barrier (full-screen blur overlay) ---
              // This layer will appear when the dropdown is open.
              if (_isDropdownOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen =
                            false; // Close dropdown on tap outside
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: Colors.black.withOpacity(0.0), // Initially transparent
                      // A BackdropFilter here will blur everything below it.
                      // Since this is above the main content, it blurs the main content.
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 5.0,
                          sigmaY: 5.0,
                        ), // Apply blur
                        child: Container(
                          color: Colors.black.withOpacity(0.1), // Light overlay color
                        ),
                      ),
                    ),
                  ),
                ),

              // --- Custom Dropdown (on top of the blur) ---
              if (_isDropdownOpen)
                Positioned(
                  top: 280,
                  right: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? Colors.grey[850]!.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 0,
                            sigmaY: 0,
                          ), // No blur on the dropdown itself
                          child: Column(
                            children: [
                              _buildDropdownItem(
                                AppConstants.student,
                                Icons.school,
                              ),
                              _buildDropdownItem(
                                AppConstants.teacher,
                                Icons.person_outline,
                              ),
                              _buildDropdownItem(
                                AppConstants.parent,
                                Icons.family_restroom,
                              ),
                              _buildDropdownItem(
                                AppConstants.admin,
                                Icons.admin_panel_settings,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getWelcomeMessage() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return AppConstants.studentWelcome;
      case AppConstants.teacher:
        return AppConstants.teacherWelcome;
      case AppConstants.parent:
        return AppConstants.parentWelcome;
      case AppConstants.admin:
        return AppConstants.adminWelcome;
      default:
        return 'Welcome Back!';
    }
  }

  String _getSubtitleMessage() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return AppConstants.studentSubtitle;
      case AppConstants.teacher:
        return AppConstants.teacherSubtitle;
      case AppConstants.parent:
        return AppConstants.parentSubtitle;
      case AppConstants.admin:
        return AppConstants.adminSubtitle;
      default:
        return 'Sign in to continue';
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case AppConstants.student:
        return Icons.school;
      case AppConstants.teacher:
        return Icons.person_outline;
      case AppConstants.parent:
        return Icons.family_restroom;
      case AppConstants.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildDropdownItem(String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = value;
          _isDropdownOpen = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedUserType == value
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedUserType == value ? Colors.blue : (isDark ? Colors.white : Colors.black87),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                color: _selectedUserType == value
                    ? Colors.blue
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: _selectedUserType == value
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
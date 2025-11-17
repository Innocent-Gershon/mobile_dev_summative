import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/role_selection_dialog.dart';
import '../../../core/constants/app_constants.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childClassController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = AppConstants.student;
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _childNameController.dispose();
    _childClassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'EduBridge',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            String displayMessage = state.message;
            bool shouldShowDialog = false;
            
            if (state.message.startsWith('SHOW_LOGIN_DIALOG:')) {
              displayMessage = state.message.substring('SHOW_LOGIN_DIALOG:'.length);
              shouldShowDialog = true;
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(displayMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            
            if (shouldShowDialog) {
              Future.delayed(const Duration(milliseconds: 800), () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(
                      children: [
                        Icon(Icons.login, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        const Text('Welcome Back!'),
                      ],
                    ),
                    content: const Text('You already have an account with this email. Would you like to login instead?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Stay Here'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Login'),
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
              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Create account text
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getSignupTitle(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getSignupSubtitle(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // User type selector
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
                                      color: Colors.blue.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
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
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Full name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppConstants.fullName,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Role-specific fields
                        if (_selectedUserType == AppConstants.student)
                          ..._buildStudentFields(),
                        if (_selectedUserType == AppConstants.teacher)
                          ..._buildTeacherFields(),
                        if (_selectedUserType == AppConstants.parent)
                          ..._buildParentFields(),

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
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: AppConstants.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final additionalData = <String, String>{
                                        'userType': _selectedUserType,
                                      };

                                      if (_selectedUserType == AppConstants.student) {
                                        additionalData['studentId'] =
                                            _studentIdController.text.trim();
                                      } else if (_selectedUserType == AppConstants.teacher) {
                                        additionalData['employeeId'] =
                                            _employeeIdController.text.trim();
                                      } else if (_selectedUserType == AppConstants.parent) {
                                        additionalData['phoneNumber'] =
                                            _phoneController.text.trim();
                                        additionalData['childName'] =
                                            _childNameController.text.trim();
                                        additionalData['childClass'] =
                                            _childClassController.text.trim();
                                      }

                                      context.read<AuthBloc>().add(
                                        SignUpWithEmailEvent(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          fullName: _nameController.text.trim(),
                                          userType: _selectedUserType,
                                          additionalData: additionalData,
                                        ),
                                      );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    AppConstants.signUp,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Privacy Policy
                        Text.rich(
                          TextSpan(
                            text: 'By signing up, you agree to EduBridge\'s ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Terms & Privacy Policy',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or Sign Up with ',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 42, 40, 40),
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
                                  side: const BorderSide(color: Colors.black26),
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
                                label: const Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading ? null : () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(color: Colors.black26),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.apple,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading ? null : () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(color: Colors.black26),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.facebook,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  'Facebook',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 42, 40, 40),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppConstants.login,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
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

              // Modal Barrier (blur overlay)
              if (_isDropdownOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: Colors.black.withValues(alpha: 0.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),

              // Custom Dropdown
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
                        color: Colors.white.withValues(alpha: 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Column(
                            children: [
                              _buildDropdownItem(AppConstants.student, Icons.school),
                              _buildDropdownItem(AppConstants.teacher, Icons.person_outline),
                              _buildDropdownItem(AppConstants.parent, Icons.family_restroom),
                              _buildDropdownItem(AppConstants.admin, Icons.admin_panel_settings),
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

  String _getSignupTitle() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return AppConstants.studentSignup;
      case AppConstants.teacher:
        return AppConstants.teacherSignup;
      case AppConstants.parent:
        return AppConstants.parentSignup;
      case AppConstants.admin:
        return AppConstants.adminSignup;
      default:
        return 'Create Account';
    }
  }

  String _getSignupSubtitle() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return 'Start your educational journey with us';
      case AppConstants.teacher:
        return 'Empower students with your expertise';
      case AppConstants.parent:
        return 'Stay connected with your child\'s education';
      case AppConstants.admin:
        return 'Manage and oversee the entire platform';
      default:
        return 'Join us and start your learning adventure';
    }
  }

  List<Widget> _buildStudentFields() {
    return [];
  }

  List<Widget> _buildTeacherFields() {
    return [];
  }

  List<Widget> _buildParentFields() {
    return [
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: AppConstants.phoneNumber,
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
          if (!RegExp(r'^[+]?[0-9]{10,15}$')
              .hasMatch(value.replaceAll(RegExp(r'[\s-()]'), ''))) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _childNameController,
        decoration: const InputDecoration(
          labelText: AppConstants.childName,
          prefixIcon: Icon(Icons.child_care_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your child\'s name';
          }
          if (value.length < 2) {
            return 'Name must be at least 2 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _childClassController,
        decoration: const InputDecoration(
          labelText: AppConstants.childClass,
          prefixIcon: Icon(Icons.class_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your child\'s class';
          }
          return null;
        },
      ),
    ];
  }

  Widget _buildDropdownItem(String value, IconData icon) {
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
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedUserType == value ? Colors.blue : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                color: _selectedUserType == value ? Colors.blue : Colors.black87,
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